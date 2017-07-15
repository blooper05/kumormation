# frozen_string_literal: true

require 'bundler'
Bundler.require

ses = Aws::SES::Client.new
arn = ARGV[0]

raise 'invalid arguments' unless arn.match?(/arn:aws:sns:us-east-1:\d{12}:SESBounce/)

ses.list_identities.identities.each do |identity|
  print %(Set bounce notifications SNS topic to "#{identity}" [y/N]? )

  next unless STDIN.gets.chomp == 'y'

  ses.set_identity_notification_topic(
    identity:          identity,
    notification_type: 'Bounce',
    sns_topic:         arn,
  )

  ses.set_identity_headers_in_notifications_enabled(
    identity:          identity,
    notification_type: 'Bounce',
    enabled:           true,
  )

  puts ':)'
end
