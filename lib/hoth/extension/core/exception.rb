class Exception
  def to_json(*a)
    {
      JSON.create_id => self.class.name,
      'm'            => self.message,
      'b'            => self.backtrace
    }.to_json(*a)
  end
  
  def self.json_create(hash)
    exception = new(hash["m"])
    exception.set_backtrace hash['b']
    exception
  end
end
