// -*- Mode: vala; indent-tabs-mode: nil; tab-width: 4 -*-
/*-
 * Copyright (c) 2013 Maya Developers (http://launchpad.net/maya)
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Library General Public
 * License as published by the Free Software Foundation; either
 * version 2 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Library General Public License for more details.
 *
 * You should have received a copy of the GNU Library General Public
 * License along with this library; if not, write to the
 * Free Software Foundation, Inc., 59 Temple Place - Suite 330,
 * Boston, MA 02111-1307, USA.
 *
 * Authored by: Corentin Noël <tintou@mailoo.org>
 */

public class Maya.GoogleBackend : GLib.Object, Maya.Backend {
    
    public string get_name () {
        return _("Google");
    }
    
    public string get_uid () {
        return "google-stub";
    }
    
    public Gee.Collection<PlacementWidget> get_new_calendar_widget (E.Source? to_edit = null) {
        var collection = new Gee.LinkedList<PlacementWidget> ();
        
        var user_label = new PlacementWidget ();
        user_label.widget = new Gtk.Label (_("User:"));
        ((Gtk.Label) user_label.widget).xalign = 1;
        user_label.row = 3;
        user_label.column = 0;
        user_label.ref_name = "user_label";
        collection.add (user_label);
        
        var user_entry = new PlacementWidget ();
        user_entry.widget = new Gtk.Entry ();
        user_entry.row = 3;
        user_entry.column = 1;
        user_entry.ref_name = "user_entry";
        collection.add (user_entry);
        
        return collection;
    }
    public void add_new_calendar (string name, string color, Gee.Collection<PlacementWidget> widgets) {
        var new_source = new E.Source (null, null);
        new_source.display_name = name;
        new_source.parent = get_uid ();
        E.SourceCalendar cal = (E.SourceCalendar)new_source.get_extension (E.SOURCE_EXTENSION_CALENDAR);
        cal.color = color;
        cal.backend_name = "caldav";
        E.SourceWebdav webdav = (E.SourceWebdav)new_source.get_extension (E.SOURCE_EXTENSION_WEBDAV_BACKEND);
        E.SourceAuthentication auth = (E.SourceAuthentication)new_source.get_extension (E.SOURCE_EXTENSION_AUTHENTICATION);
        
        foreach (var widget in widgets) {
            switch (widget.ref_name) {
                case "user_entry":
                    string decoded_user = ((Gtk.Entry)widget.widget).text;
                    if (!decoded_user.contains ("@") && !decoded_user.contains ("%40")) {
                        decoded_user = "%s@gmail.com".printf (decoded_user);
                    }
                    auth.user = decoded_user;
                    var soup_uri = new Soup.URI (null);
                    soup_uri.set_host ("www.google.com");
                    soup_uri.set_scheme ("https");
                    soup_uri.set_user (decoded_user);
                    soup_uri.set_path ("/calendar/dav/%s/events".printf (decoded_user));
                    webdav.soup_uri = soup_uri;
                    break;
            }
        }
        
        var registry = new E.SourceRegistry.sync (null);
        registry.commit_source_sync (new_source);
    }
}
