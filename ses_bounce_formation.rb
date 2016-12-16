template do
  AWSTemplateFormatVersion "2010-09-09"
  Description "This sample template creates an HTTP endpoint using AWS Elastic Beanstalk, creates an Amazon SNS topic, and subscribes the HTTP endpoint to that topic. **WARNING** This template creates one or more Amazon EC2 instances. You will be billed for the AWS resources used if you create a stack from this template."
  Parameters do
    KeyName do
      Description "Name of an existing EC2 KeyPair to enable SSH access to the Amazon EC2 instance(s) in the environment deployed for the AWS Elastic Beanstalk application in this template."
      Type "String"
      MinLength 1
      MaxLength 255
      AllowedPattern "[\\x20-\\x7E]*"
      ConstraintDescription "can contain only ASCII characters."
    end
    MyPublishUserPassword do
      NoEcho "true"
      Type "String"
      Description "Password for the IAM user MyPublishUser"
      MinLength 1
      MaxLength 41
    end
  end
  Resources do
    MySNSTopic do
      Type "AWS::SNS::Topic"
      Properties do
        Subscription do |*|
          Endpoint do
            Fn__Join [
              "/",
              [
                "http:/",
                _{
                  Fn__GetAtt "MyEndpointEnvironment", "EndpointURL"
                },
                "myendpoint"
              ]
            ]
          end
          Protocol "http"
        end
      end
    end
    MyEndpointApplication do
      Type "AWS::ElasticBeanstalk::Application"
      Properties do
        Description "HTTP endpoint to receive messages from Amazon SNS subscription."
        ApplicationVersions do |*|
          VersionLabel "Initial Version"
          Description "Version 1.0"
          SourceBundle do
            S3Bucket "cloudformation-examples"
            S3Key "sns-http-example.war"
          end
        end
        ConfigurationTemplates do |*|
          TemplateName "DefaultConfiguration"
          Description "Default Configuration Version 1.0 - with SSH access"
          SolutionStackName "32bit Amazon Linux running Tomcat 7"
          OptionSettings do |*|
            Namespace "aws:autoscaling:launchconfiguration"
            OptionName "EC2KeyName"
            Value do
              Ref "KeyName"
            end
          end
        end
      end
    end
    MyEndpointEnvironment do
      Type "AWS::ElasticBeanstalk::Environment"
      Properties do
        ApplicationName do
          Ref "MyEndpointApplication"
        end
        Description "AWS Elastic Beanstalk Environment running HTTP endpoint for Amazon SNS subscription."
        TemplateName "DefaultConfiguration"
        VersionLabel "Initial Version"
      end
    end
    MyPublishUser do
      Type "AWS::IAM::User"
      Properties do
        LoginProfile do
          Password do
            Ref "MyPublishUserPassword"
          end
        end
      end
    end
    MyPublishUserKey do
      Type "AWS::IAM::AccessKey"
      Properties do
        UserName do
          Ref "MyPublishUser"
        end
      end
    end
    MyPublishTopicGroup do
      Type "AWS::IAM::Group"
      Properties do
        Policies do |*|
          PolicyName "MyTopicGroupPolicy"
          PolicyDocument do
            Statement do |*|
              Effect "Allow"
              Action ["sns:Publish"]
              Resource do
                Ref "MySNSTopic"
              end
            end
          end
        end
      end
    end
    AddUserToMyPublishTopicGroup do
      Type "AWS::IAM::UserToGroupAddition"
      Properties do
        GroupName do
          Ref "MyPublishTopicGroup"
        end
        Users do |*|
          Ref "MyPublishUser"
        end
      end
    end
  end
  Outputs do
    MySNSTopicTopicARN do
      Description "ARN for MySNSTopic."
      Value do
        Ref "MySNSTopic"
      end
    end
    MyPublishUserInfo do
      Description "Information about MyPublishUser."
      Value do
        Fn__Join [
          " ",
          [
            "ARN:",
            _{
              Fn__GetAtt "MyPublishUser", "Arn"
            },
            "Access Key:",
            _{
              Ref "MyPublishUserKey"
            },
            "Secret Key:",
            _{
              Fn__GetAtt "MyPublishUserKey", "SecretAccessKey"
            }
          ]
        ]
      end
    end
    URL do
      Description "URL of the HTTP endpoint hosted on AWS Elastic Beanstalk and subscribed to topic."
      Value do
        Fn__Join [
          "/",
          [
            "http:/",
            _{
              Fn__GetAtt "MyEndpointEnvironment", "EndpointURL"
            },
            "myendpoint"
          ]
        ]
      end
    end
  end
end
