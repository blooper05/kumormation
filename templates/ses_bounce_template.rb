# frozen_string_literal: true

template do
  AWSTemplateFormatVersion '2010-09-09'

  Description <<~DESC.chomp
    This template creates an Amazon SNS topic, and subscribes the Amazon SQS endpoint to that topic.
  DESC

  Resources do
    MySQSQueue do
      Type 'AWS::SQS::Queue'
      Properties do
        QueueName 'SESBounceSQS'
      end
    end

    MySQSQueuePolicy do
      Type 'AWS::SQS::QueuePolicy'
      Properties do
        PolicyDocument do
          Id 'SESBounceSQSPolicy'
          Version '2012-10-17'
          Statement do
            Sid 'SESBounceSQSPolicy'
            Effect 'Allow'
            Principal '*'
            Action 'SQS:SendMessage'
            Resource { Fn__GetAtt 'MySQSQueue', 'Arn' }
            Condition do
              ArnEquals 'aws:SourceArn' do
                Ref 'MySNSTopic'
              end
            end
          end
        end
        Queues { |*| Ref 'MySQSQueue' }
      end
    end

    MySNSTopic do
      Type 'AWS::SNS::Topic'
      Properties do
        DisplayName 'SESBounce'
        Subscription do |*|
          Endpoint { Fn__GetAtt 'MySQSQueue', 'Arn' }
          Protocol 'sqs'
        end
        TopicName 'SESBounce'
      end
    end
  end

  Outputs do
    MySQSQueueQueueARN do
      Description 'ARN for MySQSQueue.'
      Value do
        Fn__GetAtt 'MySQSQueue', 'Arn'
      end
    end

    MySNSTopicTopicARN do
      Description 'ARN for MySNSTopic.'
      Value do
        Ref 'MySNSTopic'
      end
    end
  end
end

post do |output|
  puts <<~MSG

    You're almost there :)
    Run the command below and set bounce notifications SNS topic to your SES identities.

    ruby scripts/ses_bounce_script.rb '#{output['MySNSTopicTopicARN']}'
  MSG
end
