{-# LANGUAGE CPP #-}

-- | This module provides common utilities.
--
-- @since 0.1
module Pythia.Utils
  ( -- * Folding
    foldAlt,
    foldMap1,
    mAlt,

    -- * Parsing
    takeLine,
    takeLineLabel,
    takeLine_,
    exeSupported,

    -- * Miscellaneous
    headMaybe,
    eitherToBool,
  )
where

import Data.Maybe qualified as May
import Effects.FileSystem.PathReader qualified as Dir
import Pythia.Prelude
import Text.Megaparsec (Parsec, Stream, Token, Tokens)
import Text.Megaparsec qualified as MP
import Text.Megaparsec.Char qualified as MPC

-- $setup
-- >>> import Pythia.Prelude
-- >>> import Text.Megaparsec (parseTest)

-- | Similar to 'foldMap' but for 'Alternative'.
--
-- ==== __Examples__
--
-- >>> foldAlt (\c -> if even c then Just c else Nothing) [1,2,3,4]
-- Just 2
--
-- >>> foldAlt (\c -> if even c then Just c else Nothing) [1,3]
-- Nothing
--
-- @since 0.1
foldAlt :: (Foldable t, Alternative f) => (a -> f b) -> t a -> f b
foldAlt f = foldr ((<|>) . f) empty
{-# INLINEABLE foldAlt #-}

-- | Relaxes 'foldMap'\'s 'Monoid' constraint to 'Semigroup'. Requires a
-- starting value. This will have to do until semigroupoids' Foldable1 is
-- in base.
--
-- @since 0.1
foldMap1 :: (Foldable f, Semigroup s) => (a -> s) -> a -> f a -> s
foldMap1 f x xs = foldr (\b g y -> f y <> g b) f xs x
{-# INLINEABLE foldMap1 #-}

-- | Convenience function for mapping a 'Maybe' to its underlying
-- 'Alternative'.
--
-- ==== __Examples__
--
-- >>> mAlt @[] Nothing
-- []
--
-- >>> mAlt @[] (Just [1,2,3])
-- [1,2,3]
--
-- @since 0.1
mAlt :: (Alternative f) => Maybe (f a) -> f a
mAlt = fromMaybe empty
{-# INLINEABLE mAlt #-}

-- | 'takeLineLabel' with no label.
--
-- ==== __Examples__
--
-- >>> parseTest @Void takeLine "some text 123 \n"
-- "some text 123 "
--
-- >>> parseTest @Void takeLine "some text 123"
-- 1:14:
--   |
-- 1 | some text 123
--   |              ^
-- unexpected end of input
-- expecting end of line
--
-- @since 0.1
takeLine :: (Ord e, Stream s, Token s ~ Char) => Parsec e s (Tokens s)
takeLine = takeLineLabel Nothing
{-# INLINEABLE takeLine #-}

-- | Variant of 'takeLine' taking in a label.
--
-- ==== __Examples__
--
-- >>> parseTest @Void (takeLineLabel (Just "a label")) "some text 123"
-- 1:14:
--   |
-- 1 | some text 123
--   |              ^
-- unexpected end of input
-- expecting a label or end of line
--
-- @since 0.1
takeLineLabel :: (Ord e, Stream s, Token s ~ Char) => Maybe String -> Parsec e s (Tokens s)
takeLineLabel desc = MP.takeWhileP desc (/= '\n') <* MPC.eol
{-# INLINEABLE takeLineLabel #-}

-- | Takes everything up to the first new line, returns unit.
--
-- ==== __Examples__
--
-- >>> parseTest @Void takeLine_ "some text 123\n"
-- ()
--
-- @since 0.1
takeLine_ :: (Ord e, Stream s, Token s ~ Char) => Parsec e s ()
takeLine_ = MP.takeWhileP Nothing (/= '\n') *> void MPC.eol
{-# INLINEABLE takeLine_ #-}

-- | Maps 'Left' to 'False', 'Right' to 'True'.
--
-- ==== __Examples__
--
-- >>> eitherToBool (Left ())
-- False
--
-- >>> eitherToBool (Right ())
-- True
--
-- @since 0.1
eitherToBool :: Either a b -> Bool
eitherToBool = either (const False) (const True)
{-# INLINEABLE eitherToBool #-}

-- | Determines if the executable represented by the string parameter is
-- supported on this system.
--
-- @since 0.1
exeSupported :: (HasCallStack, MonadPathReader m) => OsPath -> m Bool
exeSupported exeName = May.isJust <$> Dir.findExecutable exeName
{-# INLINEABLE exeSupported #-}
