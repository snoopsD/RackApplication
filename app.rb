require 'rack'
require 'rack/response'

DATE = DateTime.now
FORMATS_TIME = { 'year' => DATE.year, 'month' => DATE.month,
  'day' => DATE.day, 'hour' => DATE.hour,
  'minute' => DATE.minute, 'second' => DATE.second }

class App

  def call(env)  
    @request = Rack::Request.new(env)
    check_request
  end

  private 
  
  def path_valid?
    @request.path == '/time'
  end

  def method_get?
    @request.get?
  end

  def params_split
    @request.params['format'].split(',')
  end

  def error_request
    return [404, { 'Content-Type' => 'text/plain' }, ["Error request!\n"] ]
  end

  def valid_params
    params_split.map { |format| FORMATS_TIME[format] }.compact.join('-')
  end

  def invalid_params
    params_split.reject { |format| FORMATS_TIME[format] }
  end

  def content_type
    { 'Content-Type' => 'text/plain' }
  end

  def status
    invalid_params.empty? ? 200 : 400 
  end

  def check_request
    if  method_get? && path_valid?
      [status, content_type, body]
    else
      error_request
    end 
  end

  def body
    if params_split.all? { |format| FORMATS_TIME.key?(format) }
      [valid_params]
    else 
      ["Unknown time format #{invalid_params}"]
    end
  end

end
