{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE UndecidableInstances #-}

-- | Provides network interface types.
--
-- @since 0.1
module Pythia.Services.NetInterface.Types
  ( -- * Configuration
    NetInterfaceApp (..),
    NetInterfaceConfig (..),

    -- * NetInterface Fields
    NetInterfaceType (..),
    NetInterfaceState (..),
    NetInterface (..),
    NetInterfaces (..),
  )
where

import Pythia.Data.RunApp (RunApp)
import Pythia.Data.Supremum (Supremum (..))
import Pythia.Prelude
import Pythia.Services.Types.Network
  ( Device,
    IpAddresses (..),
    IpType (..),
  )
import Pythia.Utils (Pretty (..), (<+>))
import Pythia.Utils qualified as U

-- | Determines how we should query the system for interface state information.
--
-- @since 0.1
data NetInterfaceApp
  = -- | Uses the Network Manager cli utility.
    --
    -- @since 0.1
    NetInterfaceNmCli
  | -- | Uses the \'ip\' utility.
    --
    -- @since 0.1
    NetInterfaceIp
  deriving stock
    ( -- | @since 0.1
      Bounded,
      -- | @since 0.1
      Enum,
      -- | @since 0.1
      Eq,
      -- | @since 0.1
      Generic,
      -- | @since 0.1
      Ord,
      -- | @since 0.1
      Show
    )
  deriving
    ( -- | @since 0.1
      Monoid,
      -- | @since 0.1
      Semigroup
    )
    via (Supremum NetInterfaceApp)
  deriving anyclass
    ( -- | @since 0.1
      NFData
    )

-- | @since 0.1
makePrismLabels ''NetInterfaceApp

-- | Complete configuration for querying network interfaces.
--
-- >>> mempty @NetInterfaceConfig
-- MkNetInterfaceConfig {interfaceApp = Many}
--
-- @since 0.1
newtype NetInterfaceConfig = MkNetInterfaceConfig
  { -- | @since 0.1
    interfaceApp :: RunApp NetInterfaceApp
  }
  deriving stock
    ( -- | @since 0.1
      Eq,
      -- | @since 0.1
      Generic,
      -- | @since 0.1
      Show
    )
  deriving anyclass
    ( -- | @since 0.1
      NFData
    )

-- | @since 0.1
makeFieldLabelsNoPrefix ''NetInterfaceConfig

-- | @since 0.1
instance Semigroup NetInterfaceConfig where
  MkNetInterfaceConfig a <> MkNetInterfaceConfig a' =
    MkNetInterfaceConfig (a <> a')

-- | @since 0.1
instance Monoid NetInterfaceConfig where
  mempty = MkNetInterfaceConfig mempty

-- | Various connection types.
--
-- @since 0.1
data NetInterfaceType
  = -- | @since 0.1
    Ethernet
  | -- | @since 0.1
    Wifi
  | -- | @since 0.1
    Wifi_P2P
  | -- | @since 0.1
    Loopback
  | -- | @since 0.1
    Tun
  deriving stock
    ( -- | @since 0.1
      Eq,
      -- | @since 0.1
      Generic,
      -- | @since 0.1
      Ord,
      -- | @since 0.1
      Show
    )
  deriving anyclass
    ( -- | @since 0.1
      NFData
    )

-- | @since 0.1
makePrismLabels ''NetInterfaceType

instance Pretty NetInterfaceType where
  pretty = pretty . show

-- | Various connection states.
--
-- @since 0.1
data NetInterfaceState
  = -- | @since 0.1
    Up
  | -- | @since 0.1
    Down
  | -- | @since 0.1
    UnknownState Text
  deriving stock
    ( -- | @since 0.1
      Eq,
      -- | @since 0.1
      Generic,
      -- | @since 0.1
      Ord,
      -- | @since 0.1
      Show
    )
  deriving anyclass
    ( -- | @since 0.1
      NFData
    )

-- | @since 0.1
makePrismLabels ''NetInterfaceState

instance Pretty NetInterfaceState where
  pretty = pretty . show

-- | Full connection data.
--
-- @since 0.1
data NetInterface = MkNetInterface
  { -- | @since 0.1
    idevice :: Device,
    -- | @since 0.1
    itype :: Maybe NetInterfaceType,
    -- | @since 0.1
    istate :: NetInterfaceState,
    -- | The name of the connection (e.g. Wifi SSID).
    --
    -- @since 0.1
    iname :: Maybe Text,
    -- | @since 0.1
    ipv4s :: IpAddresses 'Ipv4,
    -- | @since 0.1
    ipv6s :: IpAddresses 'Ipv6
  }
  deriving stock
    ( -- | @since 0.1
      Eq,
      -- | @since 0.1
      Generic,
      -- | @since 0.1
      Ord,
      -- | @since 0.1
      Show
    )
  deriving anyclass
    ( -- | @since 0.1
      NFData
    )

-- | @since 0.1
makeFieldLabelsNoPrefix ''NetInterface

-- | @since 0.1
instance Pretty NetInterface where
  pretty netif =
    U.vsep
      [ device,
        ctype,
        state,
        name,
        ipv4s,
        ipv6s
      ]
    where
      device = "Device:" <+> pretty (netif ^. #idevice)
      ctype = "Type:" <+> pretty (netif ^. #itype)
      state = "State:" <+> pretty (netif ^. #istate)
      name = "Name:" <+> pretty (netif ^. #iname)
      ipv4s = "IPv4:" <+> pretty (netif ^. #ipv4s)
      ipv6s = "IPv6:" <+> pretty (netif ^. #ipv6s)

-- | @since 0.1
newtype NetInterfaces = MkNetInterfaces
  { -- | @since 0.1
    unNetInterfaces :: [NetInterface]
  }
  deriving stock
    ( -- | @since 0.1
      Eq,
      -- | @since 0.1
      Generic,
      -- | @since 0.1
      Ord,
      -- | @since 0.1
      Show
    )
  deriving anyclass
    ( -- | @since 0.1
      NFData
    )

-- | @since 0.1
instance Pretty NetInterfaces where
  pretty = U.vsep . U.punctuate (U.pretty @Text "\n") . fmap pretty . unNetInterfaces

-- | @since 0.1
makeFieldLabelsNoPrefix ''NetInterfaces