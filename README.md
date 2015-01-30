# Description #

This fork is intended to help in creating minimal TurnKey's installations.
Most default programs were removed, such as:

* confconsole
* inithooks
* webmin

# Comparison with original "common" #

## Deleted files ##

No files were removed from [turnkeylinux/common](https://github.com/turnkeylinux/common).

## Added files ##

* <code>plans/minimalist</code>
* <code>mk/tiny.mk</code>
* <code>overlays/tiny.d</code>
* <code>conf/tiny.d</code>

# Usage

In your production setup, for instance [TurnKey Core](https://github.com/turnkeylinux-apps/core),
the file <code>plan/main</code> is able to be represented as:

```
#include <minimalist>

```

That's all. To setup default root password see
[example here](https://github.com/gh0stwizard/turnkey-tiny/blob/master/conf.d/rootpasswd)

