#
# Fluent
#
# Copyright (C) 2011 FURUHASHI Sadayuki
#
#    Licensed under the Apache License, Version 2.0 (the "License");
#    you may not use this file except in compliance with the License.
#    You may obtain a copy of the License at
#
#        http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS,
#    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#    See the License for the specific language governing permissions and
#    limitations under the License.
#
module Fluent


class FileOutput < BufferedOutput
  Plugin.register_output('file', self)

  def initialize
    super
    @format = nil
    @localtime = false
  end

  attr_accessor :format

  def configure(conf)
    super

    if path = conf['path']
      if pos = path.index('*')
        @format = "#{path[0,pos]}%Y-%m-%d-%H#{path[pos+1..-1]}"
      else
        @format = "#{path}.%Y-%m-%d-%H"
      end
    elsif format = conf['format']
      @format = format
    else
      raise ConfigError, "'path' parameter is required on file output"
    end

    # TODO timezone
    @localtime = true if conf['localtime']

    # TODO configure rotate_time
    # TODO configure rotate_size
    # TODO compression
  end

  def format(tag, event)
    # TODO foramt
    #msg = e.record.map {|k,v|
    #	k = "\"#{k}\"" if k.include?(' ')
    #	v = "\"#{v}\"" if v.include?(' ')
    #	"#{k}=#{v}"
    #}.join(' ')
    msg = event.record.to_json
    "#{Time.at(event.time).to_s} #{tag}: #{msg}\n"
  end

  def write(chunk)
    if @localtime
      time = Time.now
    else
      time = Time.now.utc
    end
    path = time.strftime(@format)
    FileUtils.mkdir_p File.dirname(path)
    File.open(path, "a") {|f|
      f.write(chunk.read)
    }
  end
end


end

