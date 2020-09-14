let
  enableMusl = rustChannel: rustChannel // {
    rust = rustChannel.rust.override (o: {
      targets    = o.targets or [] ++ ["x86_64-unknown-linux-musl"];
      extensions = o.extensions or [] ++ ["rust-src"];
    });
  };
in self: super: {
  twey = super.twey or { } // rec {
    rustChannel = enableMusl self.rustChannels.nightly;
    rust-env = with rustChannel; [
      rust
    ];
  };
}
