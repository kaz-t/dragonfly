require 'spec_helper'

describe "urls" do

  def request(app, path)
    Rack::MockRequest.new(app).get(path)
  end

  def job_should_match(array)
    Dragonfly::Response.should_receive(:new).with do |job, env|
      job.to_a.should == array
    end.and_return(mock('response', :to_response => [200, {'Content-Type' => 'text/plain'}, ["OK"]]))
  end

  let (:app) { test_app }

  it "works with old marshalled urls (including with tildes in them)" do
    url = "/BAhbBlsHOgZmSSIIPD4~BjoGRVQ"
    job_should_match [["f", "<>?"]]
    response = request(app, url)
  end

  it "blows up if it detects bad objects" do
    url = "/BAhvOgZDBjoLQHRoaW5nSSIId2VlBjoGRVQ"
    Dragonfly::Response.should_not_receive(:new)
    response = request(app, url)
    response.status.should == 404
  end

  it "works with the '%2B' character" do
    url = "/W1siZiIsIjIwMTIvMTEvMDMvMTdfMzhfMDhfNTc4X19NR181ODk5Xy5qcGciXSxbInAiLCJ0aHVtYiIsIjQ1MHg0NTA%2BIl1d/_MG_5899+.jpg"
    job_should_match [["f", "2012/11/03/17_38_08_578__MG_5899_.jpg"], ["p", "thumb", "450x450>"]]
    response = request(app, url)
  end

  it "works when '%2B' has been converted to + (e.g. with nginx)" do
    url = "/W1siZiIsIjIwMTIvMTEvMDMvMTdfMzhfMDhfNTc4X19NR181ODk5Xy5qcGciXSxbInAiLCJ0aHVtYiIsIjQ1MHg0NTA+Il1d/_MG_5899+.jpg"
    job_should_match [["f", "2012/11/03/17_38_08_578__MG_5899_.jpg"], ["p", "thumb", "450x450>"]]
    response = request(app, url)
  end
end
