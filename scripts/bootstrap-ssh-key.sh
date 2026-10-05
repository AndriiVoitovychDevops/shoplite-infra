PUBKEY_PATH = ENV.fetch("SHOPLITE_PUBKEY", File.join(Dir.home, ".ssh", "shoplite.pub"))
abort "SSH public key not found: #{PUBKEY_PATH}" unless File.exist?(PUBKEY_PATH)
PUBKEY = File.read(PUBKEY_PATH).strip