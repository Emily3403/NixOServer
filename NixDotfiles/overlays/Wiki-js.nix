self: super: {

  wiki-js = super.wiki-js.overrideAttrs (oldAttrs: {

    patches = (oldAttrs.patches or []) ++ [
      (super.fetchpatch {
        url = "https://github.com/requarks/wiki/pull/5878.patch";
        sha256 = "sha256-4MRVGXWKgOZACJo5ffpPGfNNWamiXAPGmLUp6uw2mlw=";
      })
    ];

  });

}
