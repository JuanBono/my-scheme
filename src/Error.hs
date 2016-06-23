module Error (ThrowsError, trapError, extractValue, LispError (..)) where

import Syntax
import Text.ParserCombinators.Parsec
import Control.Monad.Except

type ThrowsError = Either LispError

data LispError = NumArgs Integer [LispVal]
               | TypeMismatch String LispVal
               | Parser ParseError
               | BadSpecialForm String LispVal
               | NotFunction String String
               | UnboundVar String String
               | Default String

instance Show LispError where
  show (NumArgs expected found) = "Expected " ++ show expected ++ " args; found values " ++ unwordsList found
  show (TypeMismatch expected found) = "Invalid type: expected " ++ expected ++ ", found " ++ show found
  show (Parser parseErr) = "Parse error at " ++ show parseErr
  show (BadSpecialForm message form) = message ++ ": " ++ show form
  show (NotFunction message func) = message ++ ": " ++ show func
  show (UnboundVar message varname) = message ++ ": " ++ varname
  show (Default message) = message

trapError :: (Show a, MonadError a m) => m String -> m String
trapError action = catchError action (return . show)

extractValue :: ThrowsError a -> a
extractValue (Right val) = val
