# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: 'info@ev.church'
  layout 'mailer'
end
