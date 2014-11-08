module Shoryuken
  module Worker
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def perform_async(body, options = {})
        options ||= {}
        options[:message_attributes] ||= {}
        options[:message_attributes]['shoryuken_class'] = {
          string_value: self.to_s,
          data_type: 'String'
        }

        Shoryuken::Client.send_message(get_shoryuken_options['queue'], body, options)
      end

      def shoryuken_options(opts = {})
        @shoryuken_options = get_shoryuken_options.merge(stringify_keys(Hash(opts)))
        queue = @shoryuken_options['queue']
        queue = queue.call if queue.respond_to? :call

        Shoryuken.register_worker(queue, self)
      end

      def get_shoryuken_options # :nodoc:
        @shoryuken_options || { 'queue' => 'default', 'delete' => false, 'auto_delete' => false, 'batch' => false }
      end

      def stringify_keys(hash) # :nodoc:
        hash.keys.each do |key|
          hash[key.to_s] = hash.delete(key)
        end
        hash
      end
    end
  end
end
