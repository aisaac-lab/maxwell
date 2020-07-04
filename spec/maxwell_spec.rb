require 'json'

RSpec.describe Maxwell do
  it "has a version number" do
    expect(Maxwell::VERSION).not_to be nil
  end

  example do
    ips = 10.times.map {
      m = Maxwell.new(proxy: {
        url:  ENV.fetch('URL'),
        user: ENV.fetch('USER'),
        pass: ENV.fetch('PASS'),
      })
      res = m.get('https://api.ipify.org?format=json')
      JSON.parse(res.body)['ip'].tap { |ip| puts ip }
    }

    expect(5 < ips.uniq.count).to eq(true)
  end
end
