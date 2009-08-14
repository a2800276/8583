
class LLL < Field
  name :LLL
  length 3
  codec ASCII_Number
end

class LL < Field
  name :LL
  length 2
  codec ASCII_Number
end

class LLNVAR < Field
  name :LLNVAR
  length LL
  codec ASCII_Number
end

class LLLNVAR < Field
  name :LLLNVAR
  length LLL
  codec ASCII_Number
end

