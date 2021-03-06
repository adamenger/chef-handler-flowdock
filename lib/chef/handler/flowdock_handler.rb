#
# Copyright:: 2012, Matthias Marschall <mm@agileweboperations.com>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'chef/handler'
require 'flowdock'

class Chef
  class Handler
    class FlowdockHandler < Chef::Handler

      def initialize(options = {})
        @from = options[:from] || nil
        @flow = Flowdock::Flow.new(:api_token => options[:api_token],
                                   :source => options[:source] || "Chef Client")
      end

      def report
        if run_status.failed?
          content = "Chef Client raised an exception:<br/>"
          content << run_status.formatted_exception
          content << "<br/>"
          content << run_status.backtrace.join("<br/>")

          @from = {:name => "root", :address => "root@#{run_status.node.fqdn}"} if @from.nil?

          @flow.push_to_team_inbox(:subject => "Chef Client run on #{run_status.node} failed!",
            :content => content,
            :tags => ["chef", run_status.node.chef_environment, run_status.node.name], :from => @from)
        end
      end
    end
  end
end