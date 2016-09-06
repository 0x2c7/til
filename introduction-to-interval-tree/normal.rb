class NormalWay
  attr_accessor :array
  def initialize(size, array)
    @array = array
  end

  def query(range)
    max = @array[range.first]
    range.each do |index|
      max = @array[index] if max < @array[index]
    end
    max
  end

  def update(range, value)
    range.each do |index|
      @array[index] = value
    end
  end
end
