# copyright: 2018, The Authors

title "Verify BIG-IP availability"


# load data from Terraform output
# created by terraform output --json > inspec/bigip-ready/files/terraform.json
passwordcontent = inspec.profile.file("password.json").gsub /"/,''
addresscontent  = inspec.profile.file("mgmtips.json").gsub /"/,''

begin
  BIGIP_DNS       = addresscontent.split("\n")
  BIGIP_PORT      = 443 # params['bigip_mgmt_port']['value']
  BIGIP_PASSWORD  = passwordcontent.strip
rescue
  BIGIP_DNS       = []
  BIGIP_PORT      = ""
  BIGIP_PASSWORD  = ""
end

control "Connectivity" do
  impact 1.0
  title "BIGIP is reachable"

  BIGIP_DNS.each do |bigip_host|
    # can we reach the management port on the BIG-IP?
    describe host(bigip_host, port: BIGIP_PORT, protocol: 'tcp') do
        it { should be_reachable }
    end
  end
end 

control "bigip-cve-2020-5902" do 
  impact 1.0
  title "BIG-IP implemented CVE 2020-5902 patch"

  BIGIP_DNS.each do |bigip_host|
    describe http("https://#{bigip_host}:#{BIGIP_PORT}/tmui/login.jsp/..;/tmui/locallb/workspace/tmshCmd.jsp?command=list+auth+user+admin",
              method: 'GET',
              ssl_verify: false) do
                its('status') { should cmp 404 }
    end
  end
end


control "Declarative Onboarding Available" do
  impact 1.0
  title "BIGIP has DO"

  BIGIP_DNS.each do |bigip_host|
    # is the declarative onboarding end point available?
    describe http("https://#{bigip_host}:#{BIGIP_PORT}/mgmt/shared/declarative-onboarding/info",
              auth: {user: 'admin', pass: BIGIP_PASSWORD},
              params: {format: 'html'},
              method: 'GET',
              ssl_verify: false) do
          its('status') { should cmp 200 }
          its('headers.Content-Type') { should match 'application/json' }
    end
    describe json(content: http("https://#{bigip_host}:#{BIGIP_PORT}/mgmt/shared/declarative-onboarding/info",
              auth: {user: 'admin', pass: BIGIP_PASSWORD},
              params: {format: 'html'},
              method: 'GET',
              ssl_verify: false).body) do
          its([0,'version']) { should eq '1.11.0' }
          its([0,'release']) { should eq '1' } # this should be replaced with a test using the json resource
    end
  end
end 

control "Application Services Available" do
  impact 1.0
  title "BIGIP has AS3"

  BIGIP_DNS.each do |bigip_host|
    # is the application services end point available?
    describe http("https://#{bigip_host}:#{BIGIP_PORT}/mgmt/shared/appsvcs/info",
              auth: {user: 'admin', pass: BIGIP_PASSWORD},
              params: {format: 'html'},
              method: 'GET',
              ssl_verify: false) do
          its('status') { should cmp 200 }
          its('headers.Content-Type') { should match 'application/json' }
    end
    describe json(content: http("https://#{bigip_host}:#{BIGIP_PORT}/mgmt/shared/appsvcs/info",
              auth: {user: 'admin', pass: BIGIP_PASSWORD},
              params: {format: 'html'},
              method: 'GET',
              ssl_verify: false).body) do
          its('version') { should eq '3.18.0' }
          its('release') { should eq '4' } # this should be replaced with a test using the json resource
    end
  end
end 

control "Telemetry Streaming Available" do
  impact 1.0
  title "BIGIP has TS"

  BIGIP_DNS.each do |bigip_host|
    # is the telemetry streaming end point available?
    describe http("https://#{bigip_host}:#{BIGIP_PORT}/mgmt/shared/telemetry/info",
              auth: {user: 'admin', pass: BIGIP_PASSWORD},
              params: {format: 'html'},
              method: 'GET',
              ssl_verify: false) do
          its('status') { should cmp 200 }
          its('headers.Content-Type') { should match 'application/json' }
    end
    describe json(content: http("https://#{bigip_host}:#{BIGIP_PORT}/mgmt/shared/telemetry/info",
              auth: {user: 'admin', pass: BIGIP_PASSWORD},
              params: {format: 'html'},
              method: 'GET',
              ssl_verify: false).body) do
          its('version') { should eq '1.10.0' }
          its('release') { should eq '2' } # this should be replaced with a test using the json resource
    end
  end
end 

