module ISO8583
	class ISO8583Exception             < StandardError;    end
	class ISO8583ParseException        < ISO8583Exception; end
	class ISO8583MissingFieldException < StandardError;    end
end

