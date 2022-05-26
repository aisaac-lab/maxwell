require 'json'

RSpec.describe Maxwell do
  let(:maxwell) {
    Maxwell.new(proxy: {
      url:  ENV.fetch('URL'),
      user: ENV.fetch('USER'),
      pass: ENV.fetch('PASS'),
    })
  }

  it "has a version number" do
    expect(Maxwell::VERSION).not_to be nil
  end

  example do
    res = maxwell.get('https://gogotanaka.me/')
    expect(res.body.empty?).to eq(false)
  end

  example do
    ips = 10.times.map {
      res = Maxwell.new(proxy: {
        url:  ENV.fetch('URL'),
        user: ENV.fetch('USER'),
        pass: ENV.fetch('PASS'),
      }).get('https://api.ipify.org?format=json')
      JSON.parse(res.body)['ip'].tap { |ip| puts ip }
    }

    expect(5 < ips.uniq.count).to eq(true)
  end

  example do
    res = maxwell.get('http://google.com/')
    expect(res).to eq(nil)

    res = maxwell.get('http://google.com/', need_redirect: true)
    expect(res.body.empty?).to eq(false)
  end
end
