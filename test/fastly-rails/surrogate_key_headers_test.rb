require_relative '../test_helper'
require 'ostruct'

describe FastlyRails::SurrogateKeyHeaders do
  let(:controller_class) do
    Class.new do
      include FastlyRails::SurrogateKeyHeaders

      attr_accessor :request, :response

      def initialize
        @request = OpenStruct.new(session_options: {})
        @response = OpenStruct.new(headers: {})
      end
    end
  end

  let(:controller) { controller_class.new }

  describe '#set_surrogate_key_header' do
    it 'sets the Surrogate-Key header with a single key' do
      controller.set_surrogate_key_header('test-key')
      
      assert_equal 'test-key', controller.response.headers['Surrogate-Key']
    end

    it 'sets the Surrogate-Key header with multiple keys' do
      controller.set_surrogate_key_header('key1', 'key2', 'key3')
      
      assert_equal 'key1 key2 key3', controller.response.headers['Surrogate-Key']
    end

    it 'joins keys with spaces' do
      controller.set_surrogate_key_header('books', 'authors', 'categories')
      
      assert_equal 'books authors categories', controller.response.headers['Surrogate-Key']
    end

    it 'skips session to prevent Set-Cookie header' do
      controller.set_surrogate_key_header('test-key')
      
      assert_equal true, controller.request.session_options[:skip]
    end

    it 'handles empty arguments' do
      controller.set_surrogate_key_header
      
      assert_equal '', controller.response.headers['Surrogate-Key']
      assert_equal true, controller.request.session_options[:skip]
    end

    it 'overwrites existing Surrogate-Key header' do
      controller.response.headers['Surrogate-Key'] = 'old-key'
      controller.set_surrogate_key_header('new-key')
      
      assert_equal 'new-key', controller.response.headers['Surrogate-Key']
    end

    it 'handles keys with special characters' do
      controller.set_surrogate_key_header('key-with-dash', 'key_with_underscore', 'key/with/slash')
      
      assert_equal 'key-with-dash key_with_underscore key/with/slash', controller.response.headers['Surrogate-Key']
    end

    it 'handles numeric keys by converting to strings' do
      controller.set_surrogate_key_header(123, 456)
      
      assert_equal '123 456', controller.response.headers['Surrogate-Key']
    end

    it 'handles nil values' do
      controller.set_surrogate_key_header('key1', nil, 'key3')
      
      assert_equal 'key1  key3', controller.response.headers['Surrogate-Key']
    end

    it 'preserves duplicate keys' do
      controller.set_surrogate_key_header('duplicate', 'duplicate', 'unique')
      
      assert_equal 'duplicate duplicate unique', controller.response.headers['Surrogate-Key']
    end
  end
end