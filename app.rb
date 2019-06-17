require 'rack'
require 'rack/response'

class App

  def call(env)
    date = DateTime.now
    @formats_time = { 'year' => date.year, 'month' => date.month,
      'day' => date.day, 'hour' => date.hour,
      'minute' => date.minute, 'second' => date.second }
    @request = Rack::Request.new(env)
    flow
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

  def not_found
    return [404, { 'Content-Type' => 'text/plain' }, ["Error request!\n"] ]
  end

  def valid_params
    params_split.map { |format| @formats_time[format] }.compact.join('-')
  end

  def invalid_params
    params_split.reject { |format| @formats_time[format] }
  end

  def content_type
    { 'Content-Type' => 'text/plain' }
  end

  def flow
    if !path_valid? || !method_get?
      not_found
    elsif params_split.all? { |format| @formats_time.key?(format) }
      [200, content_type, [valid_params]]
    else
      [400, content_type, ["Unknown time format #{invalid_params}"]]
    end
  end

end
