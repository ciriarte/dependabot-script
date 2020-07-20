# 1. We want to get all PRs from dependabot
# 2. Iterate over those PRs that have been successfully tested
# 3. We want to merge those PRs

require "octokit"
require "pp"

branch_name = ENV["BRANCH_NAME"]

# Full name of the repo you want to create pull requests for.
repo_name = ENV["PROJECT_PATH"] # namespace/project

users = (ENV["USERS"] || "dependabot").split(",")

client = Octokit::Client.new(:login => 'x-access-token', :password => ENV["GITHUB_ACCESS_TOKEN"])

pull_requests = client.pull_requests(ENV["PROJECT_PATH"], :state => 'open', :base => branch_name)

pull_requests.each do |pull|
    puts "Checking status of #{pull.title}"
    status = client.combined_status(repo_name, pull.head.ref)
    if status.state == "success" and users.any?(pull.user.login)
        puts "Merging #{pull.title}"
        client.merge_pull_request(repo_name, pull.number)
    end
end
