require "maxwell/version"
require "httpclient"

class HTTPClient::Session
  def set_header(req)
    if @requested_version
      if /^(?:HTTP\/|)(\d+.\d+)$/ =~ @requested_version
        req.http_version = $1
      end
    end
    if @agent_name && req.header.get('User-Agent').empty?
      req.header.set('User-Agent', @agent_name)
    end
    if @from && req.header.get('From').empty?
      req.header.set('From', @from)
    end
    if req.header.get('Accept').empty?
      req.header.set('Accept', '*/*')
    end
    if @transparent_gzip_decompression
      req.header.set('Accept-Encoding', 'gzip,deflate')
    end
    if req.header.get('Date').empty?
      req.header.set_date_header
    end
  end
end

class Maxwell
  USER_AGENTS = {
    win_ie11:   "Mozilla/5.0 (Windows NT 6.1; WOW64; Trident/7.0; MALC; rv:11.0) like Gecko",

    mac_safari: "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_6) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/12.0 Safari/605.1.15",

    mac_chrome: "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/70.0.3538.77 Safari/537.36",
    win_chrome: "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/69.0.3497.100",

    mac_firefox: "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.13; rv:62.0) Gecko/20100101 Firefox/62.0",
    win_firefox: "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:62.0) Gecko/20100101 Firefox/62.0"
  }

  def initialize(proxy: {}, user_agent: nil)
    agent_name = if user_agent.nil?
      Maxwell::USER_AGENTS.values.sample
    else
      Maxwell::USER_AGENTS.fetch(user_agent)
    end
    puts "UA: #{agent_name}"

    @client = if proxy.empty?
      HTTPClient.new(agent_name: agent_name)
    else
      HTTPClient.new(
        proxy: proxy.fetch(:url),
        agent_name: agent_name
      ).tap do |client|
        client.set_proxy_auth(proxy.fetch(:user), proxy.fetch(:pass))
      end
    end
  end

  def get(url, need_redirect: false)
    begin
      get_res(url, need_redirect)
    rescue
      begin
        puts 'Failure 1'
        sleep 20
        get_res(url, need_redirect)
      rescue
        begin
          puts 'Failure 2'
          sleep 60 * 2
          get_res(url, need_redirect)
        rescue
          puts 'Failure 3'
          sleep 60 * 5
          get_res(url, need_redirect)
        end
      end
    end
  end

  private def get_res(url, need_redirect)
    puts "GET #{url}..."
    res = @client.get(url)
    if res.redirect?
      puts 'redirecting..!'
      if need_redirect
        puts 'need_redirect..!'
        url2 = res.headers['location'] || res.headers['Location']
        puts "GET #{url2}..."
        res2 = @client.get(url2)
        res2
      else
        nil
      end
    else
      res
    end
  end
end
