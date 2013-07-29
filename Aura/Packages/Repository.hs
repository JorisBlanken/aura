{-

Copyright 2012, 2013 Colin Woodbury <colingw@gmail.com>

This file is part of Aura.

Aura is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

Aura is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with Aura.  If not, see <http://www.gnu.org/licenses/>.

-}

module Aura.Packages.Repository
    ( pacmanRepo
    ) where

import Text.Regex.PCRE ((=~))

import Aura.Core
import Aura.Monad.Aura
import Aura.Pacman     (pacmanOutput)

import Utilities       (tripleThrd)

---

-- | Repository package source.
pacmanRepo :: Repository
pacmanRepo = Repository $ \name -> do
    v <- mostRecentVersion name
    return $ packageRepo name <$> v

packageRepo :: String -> String -> Package
packageRepo name version = Package
    { pkgName        = name
    , pkgVersion     = version
    , pkgDeps        = []  -- Let pacman handle dependencies.
    , pkgInstallType = Pacman name
    }

-- | The most recent version of a package, if it exists in the respositories.
mostRecentVersion :: String -> Aura (Maybe String)
mostRecentVersion s = extractVersion <$> pacmanOutput ["-Si", s]

-- | Takes `pacman -Si` output as input.
extractVersion :: String -> Maybe String
extractVersion ""   = Nothing
extractVersion info = Just $ tripleThrd match
    where match     = thirdLine =~ ": " :: (String,String,String)
          thirdLine = allLines !! 2  -- Version num is always the third line.
          allLines  = lines info
