module ActiveModel
  module Validations
    class ConfirmationValidator
      # fixes a bug if password == nil and password_confirmation == ""
      def validate_each(record, attribute, value)
        if (confirmed = record.send("#{attribute}_confirmation")) && (value.presence != confirmed.presence)
          record.errors.add attribute, :confirmation, options
        end
      end
    end
  end
end
