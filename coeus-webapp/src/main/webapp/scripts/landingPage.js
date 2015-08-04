function setupViewMore() {
    jQuery('.kcHome-linkGroup ul').readmore({
        speed: 200,
        collapsedHeight: 60,
        moreLink: '<a href="#"><em>view more...</em></a>',
        lessLink: '<a href="#"><em>view less</em></a>'
    });
}