require File.dirname(__FILE__) + '/../test_helper'

class SearchTest < Test::Unit::TestCase
  context "searching" do
    setup do
      @search = Twitter::Search.new
    end

    should "should be able to initialize with a search term" do
      Twitter::Search.new('httparty').query[:q].should include('httparty')
    end

    should "should be able to specify from" do
      @search.from('jnunemaker').query[:q].should include('from:jnunemaker')
    end

    should "should be able to specify to" do
      @search.to('jnunemaker').query[:q].should include('to:jnunemaker')
    end

    should "should be able to specify referencing" do
      @search.referencing('jnunemaker').query[:q].should include('@jnunemaker')
    end

    should "should alias references to referencing" do
      @search.references('jnunemaker').query[:q].should include('@jnunemaker')
    end

    should "should alias ref to referencing" do
      @search.ref('jnunemaker').query[:q].should include('@jnunemaker')
    end

    should "should be able to specify containing" do
      @search.containing('milk').query[:q].should include('milk')
    end

    should "should alias contains to containing" do
      @search.contains('milk').query[:q].should include('milk')
    end  

    should "should be able to specify hashed" do
      @search.hashed('twitter').query[:q].should include('#twitter')
    end

    should "should be able to specify the language" do
      @search.lang('en').query[:lang].should == 'en'
    end

    should "should be able to specify the number of results per page" do
      @search.per_page(25).query[:rpp].should == 25
    end

    should "should be able to specify the page number" do
      @search.page(20).query[:page].should == 20
    end

    should "should be able to specify only returning results greater than an id" do
      @search.since(1234).query[:since_id].should == 1234
    end

    should "should be able to specify geo coordinates" do
      @search.geocode('40.757929', '-73.985506', '25mi').query[:geocode].should == '40.757929,-73.985506,25mi'
    end

    should "should be able to clear the filters set" do
      @search.from('jnunemaker').to('oaknd1')
      @search.clear.query.should == {:q => []}
    end

    should "should be able to chain methods together" do
      @search.from('jnunemaker').to('oaknd1').referencing('orderedlist').containing('milk').hashed('twitter').lang('en').per_page(20).since(1234).geocode('40.757929', '-73.985506', '25mi')
      @search.query[:q].should == ['from:jnunemaker', 'to:oaknd1', '@orderedlist', 'milk', '#twitter']
      @search.query[:lang].should == 'en'
      @search.query[:rpp].should == 20
      @search.query[:since_id].should == 1234
      @search.query[:geocode].should == '40.757929,-73.985506,25mi'
    end

    context "fetching" do
      setup do
        stub_get('http://search.twitter.com:80/search.json?q=%40jnunemaker', 'search.json')
        @search = Twitter::Search.new('@jnunemaker')
        @response = @search.fetch
      end

      should "should return results" do
        @response.results.size.should == 15
      end

      should "should support dot notation" do
        first = @response.results.first
        first.text.should == %q(Someone asked about a tweet reader. Easy to do in ruby with @jnunemaker's twitter gem and the win32-sapi gem, if you are on windows.)
        first.from_user.should == 'PatParslow'
      end
      
      should "cache fetched results so multiple fetches don't keep hitting api" do
        Twitter::Search.expects(:get).never
        @search.fetch
      end
      
      should "rehit api if fetch is called with true" do
        Twitter::Search.expects(:get).once
        @search.fetch(true)
      end
    end
    
    context "iterating over results" do
      setup do
        stub_get('http://search.twitter.com:80/search.json?q=from%3Ajnunemaker', 'search_from_jnunemaker.json')
        @search.from('jnunemaker')
      end
      
      should "work" do
        @search.each { |result| result.should_not be(nil) }
      end
      
      should "work multiple times in a row" do
        @search.each { |result| result.should_not be(nil) }
        @search.each { |result| result.should_not be(nil) }
      end
    end
    
    should "should be able to iterate over results" do
      @search.respond_to?(:each).should be(true)
    end
  end
  
end