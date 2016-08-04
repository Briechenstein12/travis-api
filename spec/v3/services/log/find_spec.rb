require 'spec_helper'

describe Travis::API::V3::Services::Log::Find, set_app: true do
  let(:user)        { Travis::API::V3::Models::User.find_by_login('svenfuchs') }
  let(:repo)        { Travis::API::V3::Models::Repository.where(owner_name: user.login, name: 'minimal').first }
  let(:build)       { repo.builds.last }
  let(:job)         { Travis::API::V3::Models::Build.find(build.id).jobs.last }
  let(:token)       { Travis::Api::App::AccessToken.create(user: user, app_id: 1) }
  let(:headers)     { { 'HTTP_AUTHORIZATION' => "token #{token}" } }
  let(:parsed_body) { JSON.load(body) }

  context 'when log stored in db' do
    describe 'returns the Log with an array of Log Parts' do
      let(:log)       { job.log }

      example do
        log_part = log.log_parts.create(content: "logging it", number: 0)
        get("/v3/job/#{job.id}/log", {}, headers)
        expect(parsed_body).to eq(
          '@href' => "/v3/job/#{job.id}/log",
          '@representation' => 'standard',
          '@type' => 'log',
          'content' => nil,
          'id' => log.id,
          'log_parts'       => [{
          "@type"           => "log_part",
          "@representation" => "minimal",
          "content"         => log_part.content,
          "number"          => log_part.number }])
      end
    end
  end

  context 'when log not found in db but stored on S3' do
    describe 'returns log as plain text'
    describe 'returns log as chunked json'
  end

  context 'when log not found anywhere' do
    describe 'does not return log'
  end

  context 'when log removed by user' do
    describe 'does not return log'
  end
end
