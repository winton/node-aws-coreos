Docker = require "node-aws-coreos/lib/docker"

sidekick = new Docker.Args(
  "sidekick"
  env:
    DOCKER_SOCKET_PATH: "/var/run"
    ENV: "production"
)

www = new Docker.Args("www", env: ENV: "production")

availability_zone = "us-west-1c"

module.exports = 
  AWSTemplateFormatVersion: "2010-09-09"
  Description: "CoreOS on EC2: http://coreos.com/docs/running-coreos/cloud-providers/ec2/"
  Mappings:
    RegionMap:
      "eu-central-1":
        AMI: "ami-487d4d55"

      "ap-northeast-1":
        AMI: "ami-decfc0df"

      "sa-east-1":
        AMI: "ami-cb04b4d6"

      "ap-southeast-2":
        AMI: "ami-d1e981eb"

      "ap-southeast-1":
        AMI: "ami-83406fd1"

      "us-east-1":
        AMI: "ami-705d3d18"

      "us-west-2":
        AMI: "ami-4dd4857d"

      "us-west-1":
        AMI: "ami-17fae852"

      "eu-west-1":
        AMI: "ami-783a840f"

  Parameters:
    InstanceType:
      Description: "EC2 HVM instance type (m3.medium, etc)."
      Type: "String"
      Default: "t2.small"
      AllowedValues: [
        "m3.medium"
        "m3.large"
        "m3.xlarge"
        "m3.2xlarge"
        "c3.large"
        "c3.xlarge"
        "c3.2xlarge"
        "c3.4xlarge"
        "c3.8xlarge"
        "cc2.8xlarge"
        "cr1.8xlarge"
        "hi1.4xlarge"
        "hs1.8xlarge"
        "i2.xlarge"
        "i2.2xlarge"
        "i2.4xlarge"
        "i2.8xlarge"
        "r3.large"
        "r3.xlarge"
        "r3.2xlarge"
        "r3.4xlarge"
        "r3.8xlarge"
        "t2.micro"
        "t2.small"
        "t2.medium"
      ]
      ConstraintDescription: "Must be a valid EC2 HVM instance type."

    ClusterSize:
      Default: "3"
      MinValue: "3"
      MaxValue: "12"
      Description: "Number of nodes in cluster (3-12)."
      Type: "Number"

    DiscoveryURL:
      Description: "An unique etcd cluster discovery URL. Grab a new token from https://discovery.etcd.io/new"
      Type: "String"

    AdvertisedIPAddress:
      Description: "Use 'private' if your etcd cluster is within one region or 'public' if it spans regions or cloud providers."
      Default: "private"
      AllowedValues: [
        "private"
        "public"
      ]
      Type: "String"

    AllowSSHFrom:
      Description: "The net block (CIDR) that SSH is available to."
      Default: "0.0.0.0/0"
      Type: "String"

    KeyPair:
      Default: "Cyclops"
      Description: "The name of an EC2 Key Pair to allow SSH access to the instance."
      Type: "String"

  Resources:

    VPC:
      Type: "AWS::EC2::VPC"
      Properties:
        CidrBlock: "10.0.0.0/16"

    Subnet:
      Type: "AWS::EC2::Subnet"
      Properties:
        VpcId:
          Ref: "VPC"

        CidrBlock: "10.0.0.0/24"
        AvailabilityZone: availability_zone

    InternetGateway:
      Type: "AWS::EC2::InternetGateway"

    AttachGateway:
      Type: "AWS::EC2::VPCGatewayAttachment"
      Properties:
        VpcId:
          Ref: "VPC"

        InternetGatewayId:
          Ref: "InternetGateway"

    RouteTable:
      Type: "AWS::EC2::RouteTable"
      Properties:
        VpcId:
          Ref: "VPC"

    Route:
      Type: "AWS::EC2::Route"
      DependsOn: "AttachGateway"
      Properties:
        RouteTableId:
          Ref: "RouteTable"

        DestinationCidrBlock: "0.0.0.0/0"
        GatewayId:
          Ref: "InternetGateway"

    SubnetRouteTableAssociation:
      Type: "AWS::EC2::SubnetRouteTableAssociation"
      Properties:
        SubnetId:
          Ref: "Subnet"

        RouteTableId:
          Ref: "RouteTable"

    NetworkAcl:
      Type: "AWS::EC2::NetworkAcl"
      Properties:
        VpcId:
          Ref: "VPC"

    InboundAclEntry:
      Type: "AWS::EC2::NetworkAclEntry"
      Properties:
        NetworkAclId:
          Ref: "NetworkAcl"

        RuleNumber: "100"
        Protocol: "6"
        RuleAction: "allow"
        Egress: "false"
        CidrBlock: "0.0.0.0/0"
        PortRange:
          From: "0"
          To: "65535"


    OutboundAclEntry:
      Type: "AWS::EC2::NetworkAclEntry"
      Properties:
        NetworkAclId:
          Ref: "NetworkAcl"

        RuleNumber: "100"
        Protocol: "6"
        RuleAction: "allow"
        Egress: "true"
        CidrBlock: "0.0.0.0/0"
        PortRange:
          From: "0"
          To: "65535"

    SubnetNetworkAclAssociation:
      Type: "AWS::EC2::SubnetNetworkAclAssociation"
      Properties:
        SubnetId:
          Ref: "Subnet"

        NetworkAclId:
          Ref: "NetworkAcl"

    SecurityGroup:
      Type: "AWS::EC2::SecurityGroup"
      Properties:
        GroupDescription: "Enable SSH, HTTP, HTTPS, and all VPN and outgoing traffic"
        VpcId:
          Ref: "VPC"

        SecurityGroupIngress: [
          {
            IpProtocol: "tcp"
            FromPort: "22"
            ToPort: "22"
            CidrIp: "0.0.0.0/0"
          }
          {
            IpProtocol: "tcp"
            FromPort: "80"
            ToPort: "80"
            CidrIp: "0.0.0.0/0"
          }
          {
            IpProtocol: "tcp"
            FromPort: "443"
            ToPort: "443"
            CidrIp: "0.0.0.0/0"
          }
        ]
        SecurityGroupEgress: [
          IpProtocol: "tcp"
          FromPort: "0"
          ToPort: "65535"
          CidrIp: "0.0.0.0/0"
        ]

    SecurityGroupIngress:
      Type: "AWS::EC2::SecurityGroupIngress"
      DependsOn : "SecurityGroup"
      Properties:
        GroupId:
          "Fn::GetAtt": [ "SecurityGroup", "GroupId" ]
        IpProtocol: "tcp"
        FromPort: "0"
        ToPort: "65535"
        SourceSecurityGroupId:
          "Fn::GetAtt": [ "SecurityGroup", "GroupId" ]

    ElasticLoadBalancer:
      Type: "AWS::ElasticLoadBalancing::LoadBalancer"
      Properties:
        CrossZone: "true"
        SecurityGroups: [ Ref: "SecurityGroup" ]
        Subnets: [Ref: "Subnet"]
        Listeners: [
          {
            Protocol: "HTTP"
            LoadBalancerPort: "80"
            InstancePort: "80"
          }
          {
            Protocol: "HTTPS"
            LoadBalancerPort: "443"
            InstancePort: "80"
            SSLCertificateId:
              "Fn::Join": [
                ""
                [
                  "arn:aws:iam::"
                  {
                    Ref: "AWS::AccountId"
                  }
                  ":server-certificate/cyclo_ps"
                ]
              ]
          }
        ]
        HealthCheck:
          Target: "HTTP:80/"
          HealthyThreshold: "3"
          UnhealthyThreshold: "5"
          Interval: "30"
          Timeout: "25"

    CoreOSServerAutoScale:
      Type: "AWS::AutoScaling::AutoScalingGroup"
      Properties:
        AvailabilityZones: [ availability_zone ]
        LoadBalancerNames: [ Ref: "ElasticLoadBalancer" ]
        LaunchConfigurationName:
          Ref: "CoreOSServerLaunchConfig"

        MinSize: "3"
        MaxSize: "12"
        DesiredCapacity:
          Ref: "ClusterSize"

        VPCZoneIdentifier: [Ref: "Subnet"]

    CoreOSServerLaunchConfig:
      Type: "AWS::AutoScaling::LaunchConfiguration"
      DependsOn : "AttachGateway"
      Properties:
        AssociatePublicIpAddress: "true"

        ImageId:
          "Fn::FindInMap": [
            "RegionMap"
            {
              Ref: "AWS::Region"
            }
            "AMI"
          ]

        InstanceType:
          Ref: "InstanceType"

        KeyName:
          Ref: "KeyPair"

        SecurityGroups: [Ref: "SecurityGroup"]
        UserData:
          "Fn::Base64":
            "Fn::Join": [
              ""
              [
                """#cloud-config

                coreos:
                  etcd:
                    discovery: """
                Ref: "DiscoveryURL"
                """
                \n
                    addr: $"""
                Ref: "AdvertisedIPAddress"
                
                """_ipv4:4001
                \n
                    peer-addr: $"""
                Ref: "AdvertisedIPAddress"
                """_ipv4:7001
                  units:
                    - name: etcd.service
                      command: start
                    - name: fleet.service
                      command: start
                write_files:
                  - path: /home/core/.dockercfg
                    owner: core:core
                    permissions: 0644
                    content: |
                      {
                        "quay.io": {
                          "auth": "d2ludG9uK2N5Y2xvcHM6Mzc4MUpPQzZIOEdXTFpBQlZNTEozNzRXVEZSQ0lBVDNSTzVBSFZSQzFWUlBKNEI4NTlMMktHSktGNkg1Vlo0UA==",
                          "email": ""
                        }
                      }
                  - path: /services/sidekick.service
                    owner: core:core
                    permissions: 0644
                    content: |
                      [Unit]
                      Description=Sidekick container starter
                      After=docker.service
                      Requires=docker.service

                      [Service]
                      TimeoutStartSec=0
                      User=core
                      ExecStartPre=/usr/bin/docker pull #{sidekick.image()}
                      ExecStart=/usr/bin/docker run #{sidekick.cliParams().join(" ")}
                      ExecStop=/usr/bin/docker stop #{sidekick.containerName()}

                      [X-Fleet]
                      Global=true
                  - path: /services/www@.service
                    owner: core:core
                    permissions: 0644
                    content: |
                      [Unit]
                      Description=Nginx container
                      After=docker.service
                      Requires=docker.service

                      [Service]
                      TimeoutStartSec=0
                      User=core
                      ExecStartPre=/usr/bin/docker pull #{www.image()}
                      ExecStart=/usr/bin/docker run #{www.cliParams().join(" ")}
                      ExecStop=/usr/bin/docker stop #{www.containerName()}

                      [X-Fleet]
                      Conflicts=www@*.service
                """
              ]
            ]