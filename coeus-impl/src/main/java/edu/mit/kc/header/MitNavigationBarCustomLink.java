package edu.mit.kc.header;

import org.kuali.rice.krad.uif.element.NavigationBar;
import org.kuali.rice.krad.uif.component.Component;

import java.io.Serializable;

public class MitNavigationBarCustomLink extends NavigationBar implements Serializable{
    private static final long serialVersionUID = -8506955451519034958L;

    private Component brandImageLink;

   	public Component getBrandImageLink() {
   		return brandImageLink;
   	}

   	public void setBrandImageLink(Component brandImageLink) {
   		this.brandImageLink = brandImageLink;
   	}
}
