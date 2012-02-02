require 'helper'

class UakariTest < Test::Unit::TestCase

  context "attribute" do
    
    setup do
      @api_key = "123-us1"
    end
    
    context "API key" do
    
      should "not be set by default" do
        u = Uakari.new
        assert_equal(u.api_key, nil)
      end
      
      should "be settable by constructor" do
        u = Uakari.new(@api_key)
        assert_equal u.api_key, @api_key
      end
      
      should "be settable by environment variable MC_API_KEY" do
        ENV['MC_API_KEY'] = @api_key
        u = Uakari.new
        assert_equal u.api_key, @api_key
        ENV.delete('MC_API_KEY')
      end
      
      should "be settable by environment vairiable MAILCHIMP_API_KEY" do
        ENV['MAILCHIMP_API_KEY'] = @api_key
        u = Uakari.new
        assert_equal u.api_key, @api_key
        ENV.delete('MAILCHIMP_API_KEY')        
      end
      
      should "be settable by class attribute" do
        Uakari.api_key = @api_key
        u = Uakari.new
        assert_equal u.api_key, @api_key
        Uakari.api_key = nil
      end
      
      should "be settable by setter method" do
        u = Uakari.new
        u.api_key = @api_key
        assert_equal u.api_key, @api_key
      end
      
    end
    
    context "timeout" do
      
      should "be settable" do
        u = Uakari.new
        u.timeout = 30
        assert_equal u.timeout, 30
      end

    end

  end
  
  context "build api url" do
    
    setup do
      @u = Uakari.new
      @url = "https://us1.sts.mailchimp.com/1.0/SayHello"
    end

    should "handle empty api key" do
      expect_post(@url, {"apikey" => nil})
      @u.say_hello
    end

    should "handle malformed api key" do
      @api_key = "123"
      @u.api_key = @api_key
      expect_post(@url, {"apikey" => @api_key})
      @u.say_hello
    end

    should "handle timeout" do
      expect_post(@url, {"apikey" => nil}, 120)
      @u.timeout=120
      @u.say_hello
    end

    should "handle api key with dc" do
      @api_key = "TESTKEY-us1"
      @u.api_key = @api_key
      expect_post("https://us1.sts.mailchimp.com/1.0/SayHello", {"apikey" => @api_key})
      @u.say_hello
    end
  end

  private

  def expect_post(expected_url, expected_body, expected_timeout=nil)
    Uakari.expects(:post).with do |url, opts|
      url == expected_url &&
      JSON.parse(URI::decode(opts[:body])) == expected_body &&
      opts[:timeout] == expected_timeout
    end.returns(Struct.new(:body).new("") )
  end

end
