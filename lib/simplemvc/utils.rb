class String
  def to_snake_case
    self.gsub("::", "/").
      gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2').  #FooBar --> foo_bar
      gsub(/([a-z\d])([A-Z])/, '\1_\2').   #Foo86OBar --> foo86_o_bar
      tr("-", "_").
      downcase
  end

  def to_camel_case
    # If self isn't like /_/ AND is like any number of caps with any characters followed by.
    return self if self !~ /_/ && self =~ /[A-Z]+.*/

    # If not.
    split('_').map { |str| str.capitalize }.join  #foo_bar --> FooBar
  end
end
