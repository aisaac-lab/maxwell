require "maxwell/version"
require "maxwell/user_agent"
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
  def initialize(proxy: {}, user_agent: nil)
    agent_name = if user_agent.nil?
      Maxwell::UserAgent.get
    else
      user_agent
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

    @client.ssl_config.verify_mode = OpenSSL::SSL::VERIFY_NONE
  end

  def get(url, need_redirect: false, max_try_count: 5)
    try = 0
    begin
      try += 1
      get_res(url, need_redirect)
    rescue => ex
      puts "Failure #{try} #{ex.message}"
      sleep try ** 3 * 10
      retry if try < max_try_count
      raise ex
    end
  end

  private def get_res(url, need_redirect)
    puts "GET #{url}..."
    res = @client.get(url)
    if res.redirect?
      puts 'redirecting...'
      if need_redirect
        puts 'need_redirect...'
        url2 = res.headers['location'] || res.headers['Location']
        unless url2.match(/http/)
          if url2.match(%r|\A/|)
            url2 = "#{URI(url).scheme}://#{URI(url).host}#{url2}"
          else
            raise "something wrong: url2=#{url2}"
          end
        end

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
