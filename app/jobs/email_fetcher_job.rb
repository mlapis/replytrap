class EmailFetcherJob < ApplicationJob
  def perform
    puts "EmailFetcherJob started"
    EmailAccount.all.each do |email_account|
      puts "Processing email account: #{email_account.email}"
      begin
        Timeout.timeout(60) do
          EmailFetcher.new(email_account).fetch_emails
        end
      rescue Timeout::Error => e
        puts "Timeout fetching emails for #{email_account.email}: #{e.message}"
      rescue => e
        puts "Error fetching emails for #{email_account.email}: #{e.message}"
      end
    end
    puts "EmailFetcherJob completed"
  end
end
