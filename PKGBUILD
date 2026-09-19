pkgname=rext
pkgver=0.6.0
pkgrel=1
pkgdesc="Raccoon Enhanced X-platform Text Editor"
arch=('any')
depends=('lua')
source=('rext.lua')

package() {
    install -Dm755 "${srcdir}/rext.lua" "${pkgdir}/usr/bin/rext"
}
