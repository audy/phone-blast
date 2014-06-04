require 'bundler'
require 'sinatra'
require 'twilio-ruby'
require 'net/http'
require 'cgi'

sid = ['TWILIO_SID']
tok = ['TWILIO_TOKEN']

@client = Twilio::REST::Client.new sid, tok

Response = Twilio::TwiML::Response

# Le Routes
get '/' do
  res = Response.new do |r|
    r.Gather(:action => '/blast/', :numDigits => 1) do
      r.Say "Hello. Welcome to phone blast! press 1 for protein, 2 for nucleotide"
    end
  end
  res.text
end

post '/blast/?' do
  type = params[:Digits]
  type_name =
    case params[:Digits]
    when '1'
      'protein'
    when '2'
      'nucleotide'
    else
      return Response.new { |r| "unknown type #{type}. Goodbye" }.text
    end

  res = Response.new do |r|
    r.Gather(:action => '/query/', :finishOnKey => '0') do
      r.Say "You have selected nucleotide.
      Enter your sequence using numbers 1 for Adenine, 2 for Thymine, 3 for Cytosine and four for Guanine. Press zero to submit your query."
    end
  end

  res.text
end

post '/query/?' do
  trans = {
    '1' => 'A',
    '2' => 'T',
    '3' => 'C',
    '4' => 'G'
  }
  sequence = params[:Digits].chars.collect { |x| trans[x] }.join('')
  puts params.inspect
  res = Response.new do |r|
    result = Net::HTTP.get(URI.parse("http://triplab.ad.ufl.edu:4567/blast/#{sequence}?program=test"))
    # here is where blast goes
    r.Say("Your result is: #{result}. Have a nice day!")
  end
  puts res.text
  res.text
end

run Sinatra::Application
