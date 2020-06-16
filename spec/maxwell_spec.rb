require 'JSON'

RSpec.describe Maxwell do
  it "has a version number" do
    expect(Maxwell::VERSION).not_to be nil
  end

  example do
    # m = Maxwell.new(proxy: {
    #   url: ,
    #   user: ,
    #   pass: 
    # })
    # json = JSON.parse m.get('https://xxxx/inspect')

    # expect(json['HTTP_USER_AGENT']).not_to include('ruby')
  end
end
