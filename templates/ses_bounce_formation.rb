template do
  AWSTemplateFormatVersion '2010-09-09'

  Description <<~EOS
    This template creates an Amazon SNS topic, and subscribes the Amazon SQS endpoint to that topic.
  EOS

  Resources do
    MySQSQueue do
      Type 'AWS::SQS::Queue'
      Properties do
        QueueName 'SESBounceSQS'
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
    MySQSQueueQueueURL do
      Description 'URL for MySQSQueue.'
      Value do
        Ref 'MySQSQueue'
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
