// -*- Mode: vala; indent-tabs-mode: nil; tab-width: 4 -*-
/*-
 * Copyright (c) 2013 Birdie Developers (http://launchpad.net/birdie)
 *
 * This software is licensed under the GNU General Public License
 * (version 3 or later). See the COPYING file in this distribution.
 *
 * You should have received a copy of the GNU Library General Public
 * License along with this software; if not, write to the
 * Free Software Foundation, Inc., 59 Temple Place - Suite 330,
 * Boston, MA 02111-1307, USA.
 *
 * Authored by: Ivo Nunes <ivo@elementaryos.org>
 *              Vasco Nunes <vascomfnunes@gmail.com>
 */

namespace Birdie.Widgets {

    public class UserBox : Gtk.Box {

        public User user;
        public Birdie birdie;
        private Gtk.Box user_box;
        private Gtk.Box buttons_box;
        private Gtk.Alignment buttons_alignment;
        private Gtk.Image avatar_img;
        private Gtk.Image verified_img;
        private Gtk.Label username_label;
        private Gtk.Button follow_button;
        private Gtk.Button unfollow_button;
        private Gtk.Button block_button;
        private Gtk.Button unblock_button;

        public UserBox () {
            GLib.Object (orientation: Gtk.Orientation.HORIZONTAL);
        }

        public void init (User user, Birdie birdie) {
            this.birdie = birdie;
            this.user = user;

            // tweet box
            this.user_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
            this.pack_start (this.user_box, true, true, 0);

            // avatar image
            this.avatar_img = new Gtk.Image ();
            this.avatar_img.set_from_file (Constants.PKGDATADIR + "/default.png");
            this.avatar_img.set_halign (Gtk.Align.CENTER);
            this.avatar_img.set_valign (Gtk.Align.START);
            this.avatar_img.margin_top = 12;
            this.user_box.pack_start (this.avatar_img, true, true, 0);

            user.screen_name = Utils.escape_amp (user.screen_name);
            user.name = Utils.escape_amp (user.name);
            user.desc = Utils.escape_amp (user.desc);
            user.location = Utils.escape_amp (user.location);

            string tweets_txt = _("TWEETS");

            string description_txt = user.desc +
                "\n\n<span size='small' color='#666666'>" + tweets_txt +
                " </span><span size='small' font_weight='bold'>" + user.statuses_count.to_string() + "</span>" +
                " | <span size='small' color='#666666'> " + _("FOLLOWING") +
                " </span><span size='small' font_weight='bold'>" + user.friends_count.to_string() + "</span>" +
                " | <span size='small' color='#666666'> " + _("FOLLOWERS") +
                " </span><span size='small' font_weight='bold'>" + user.followers_count.to_string() + "</span>";

            description_txt = description_txt.chomp ();

            string txt = "<span underline='none' color='#000000' font_weight='bold' size='x-large'>" +
                user.name + "</span> <span font_weight='light' color='#aaaaaa'>\n@" + user.screen_name + "</span>";

            if (user.location != "")
                txt = txt +  "\n<span size='small'>" + user.location + "</span>";

            if (description_txt != "")
                txt = txt +  "\n\n" + description_txt;

            // user label
            this.username_label = new Gtk.Label (user.screen_name);
            this.username_label.set_halign (Gtk.Align.CENTER);
            this.username_label.set_valign (Gtk.Align.CENTER);

            // this.verified_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
            this.verified_img = new Gtk.Image ();
            this.verified_img.set_from_icon_name ("twitter-verified", Gtk.IconSize.BUTTON);
            this.verified_img.set_halign (Gtk.Align.CENTER);
            this.verified_img.set_valign (Gtk.Align.CENTER);
            this.verified_img.set_no_show_all (true);
            this.user_box.pack_start (this.verified_img, false, true, 0);
            this.username_label.set_markup (txt);
            this.username_label.set_halign (Gtk.Align.CENTER);
            this.username_label.set_justify (Gtk.Justification.CENTER);
            this.user_box.pack_start (this.username_label, false, true, 0);

            this.username_label.set_line_wrap (true);
            this.user_box.margin_left = 12;
            this.user_box.margin_right = 12;

            // buttons alignment
            this.buttons_alignment = new Gtk.Alignment (0,0,1,1);
            this.buttons_alignment.top_padding = 6;
            this.buttons_alignment.right_padding = 12;
            this.buttons_alignment.bottom_padding = 6;
            this.buttons_alignment.left_padding = 6;
            this.buttons_alignment.set_valign (Gtk.Align.CENTER);
            this.user_box.pack_start (this.buttons_alignment, true, true, 0);

            // buttons box
            this.buttons_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
            this.buttons_box.set_valign (Gtk.Align.FILL);
            this.buttons_alignment.add (this.buttons_box);

            // follow button
            this.follow_button = new Gtk.Button.with_label (_("Follow"));
            this.follow_button.set_halign (Gtk.Align.END);
            this.follow_button.set_tooltip_text (_("Follow user"));
            this.buttons_box.pack_start (this.follow_button, false, true, 0);

            this.follow_button.clicked.connect (() => {
                new Thread<void*> (null, this.follow_thread);
            });

            // unfollow button
            this.unfollow_button = new Gtk.Button.with_label (_("Unfollow"));
            this.unfollow_button.set_halign (Gtk.Align.END);
            this.unfollow_button.set_tooltip_text (_("Unfollow user"));
            this.buttons_box.pack_start (this.unfollow_button, false, true, 0);

            this.unfollow_button.clicked.connect (() => {
                new Thread<void*> (null, this.unfollow_thread);
            });

            // block button
            this.block_button = new Gtk.Button.with_label (_("Block"));
            this.block_button.set_halign (Gtk.Align.END);
            this.block_button.set_tooltip_text (_("Block user"));
            this.buttons_box.pack_start (this.block_button, false, true, 0);

            this.block_button.clicked.connect (() => {
                new Thread<void*> (null, this.block_thread);
            });

            // unblock button
            this.unblock_button = new Gtk.Button.with_label (_("Unblock"));
            this.unblock_button.set_halign (Gtk.Align.END);
            this.unblock_button.set_tooltip_text (_("Unblock user"));
            this.buttons_box.pack_start (this.unblock_button, false, true, 0);

            this.unblock_button.clicked.connect (() => {
                new Thread<void*> (null, this.unblock_thread);
            });

            // css
            var d_provider = new Gtk.CssProvider ();
            string? css_dir = null;

            if (this.birdie.elementary) {
                css_dir = "/usr/share/themes/elementary/gtk-3.0";
                File file = File.new_for_path (css_dir);
                File child = file.get_child ("button.css");

                try
                {
                    d_provider.load_from_file (child);
                }
                catch (GLib.Error error)
                {
                    stderr.printf("Could not load css for button: %s", error.message);
                }

                follow_button.get_style_context ().add_provider (d_provider, Gtk.STYLE_PROVIDER_PRIORITY_THEME);
                follow_button.get_style_context().add_class ("affirmative");

                block_button.get_style_context ().add_provider (d_provider, Gtk.STYLE_PROVIDER_PRIORITY_THEME);
                block_button.get_style_context().add_class ("noundo");

                unfollow_button.get_style_context ().add_provider (d_provider, Gtk.STYLE_PROVIDER_PRIORITY_THEME);
                unfollow_button.get_style_context().add_class ("noundo");

                unblock_button.get_style_context ().add_provider (d_provider, Gtk.STYLE_PROVIDER_PRIORITY_THEME);
                unblock_button.get_style_context().add_class ("affirmative");
            }

            this.unfollow_button.set_no_show_all (true);
            this.unblock_button.set_no_show_all (true);
            this.follow_button.set_no_show_all (true);
            this.block_button.set_no_show_all (true);

            this.show_all ();
            this.hide_buttons ();

            if (user.verified)
                this.verified_img.show ();
        }

        public void update (User user) {
            this.user = user;
            Array<string> friendship = new Array<string> ();

            this.avatar_img.set_from_file (Environment.get_home_dir () + "/.cache/birdie/" + user.profile_image_file);

            user.screen_name = Utils.escape_amp (user.screen_name);
            user.name = Utils.escape_amp (user.name);
            user.desc = Utils.escape_amp (user.desc);
            user.location = Utils.escape_amp (user.location);

            string followed_by = "";

            if (user.screen_name != this.birdie.api.account.screen_name) {
                friendship = this.birdie.api.get_friendship (this.birdie.api.account.screen_name, user.screen_name);
                if (friendship.index (0) == "true") {
                    this.unfollow_button.show ();
                } else {
                    this.follow_button.show ();
                }

                if (friendship.index (1) == "true") {
                    this.unblock_button.show ();
                } else {
                    this.block_button.show ();
                }

                if (friendship.index (2) == "true") {
                    followed_by = _("Following you.");
                } else {
                    followed_by = _("Not following you.");
                }
            }

            string tweets_txt = _("TWEETS");

            string description_txt = Utils.highlight_all (user.desc) + "\n\n<span size='small' color='#666666'>" + followed_by + "</span>" +
                "\n\n<span size='small' color='#666666'>" + tweets_txt +
                " </span><span size='small' font_weight='bold'>" + user.statuses_count.to_string() + "</span>" +
                " | <span size='small' color='#666666'> " + _("FOLLOWING") +
                " </span><span size='small' font_weight='bold'>" + user.friends_count.to_string() + "</span>" +
                " | <span size='small' color='#666666'> " + _("FOLLOWERS") +
                " </span><span size='small' font_weight='bold'>" + user.followers_count.to_string() + "</span>";

            description_txt = description_txt.chomp ();

            string txt = "<span underline='none' color='#000000' font_weight='bold' size='x-large'>" +
                user.name + "</span> <span font_weight='light' color='#aaaaaa'>\n@" + user.screen_name + "</span>";

            if (user.location != "")
                txt = txt +  "\n<span size='small'>" + user.location + "</span>";

            if (description_txt != "")
                txt = txt +  "\n\n" + description_txt;

            this.username_label.set_markup (txt);

            this.show_all ();
            this.hide_buttons ();
            this.verified_img.hide ();

            if (user.verified)
                this.verified_img.show ();
        }

        public void hide_buttons () {
            this.follow_button.hide ();
            this.unfollow_button.hide ();
            this.block_button.hide ();
            this.unblock_button.hide ();
        }

        private void* follow_thread () {
            Idle.add( () => {
                var reply = this.birdie.api.create_friendship (user.screen_name);

                if (reply == 0) {
                    this.hide_buttons ();
                    this.unfollow_button.show ();
                    this.block_button.show ();
                }
                return false;
            });

            return null;
        }

        private void* unfollow_thread () {
            Idle.add( () => {
                var reply = this.birdie.api.destroy_friendship (user.screen_name);

                if (reply == 0) {
                    this.hide_buttons ();
                    this.follow_button.show ();
                    this.block_button.show ();
                }
                return false;
            });

            return null;
        }

        private void* block_thread () {
            Idle.add( () => {
                var reply = this.birdie.api.create_block (user.screen_name);

                if (reply == 0) {
                    this.hide_buttons ();
                    this.follow_button.show ();
                    this.unblock_button.show ();
                }
                return false;
            });

            return null;
        }

        private void* unblock_thread () {
            Idle.add( () => {
                var reply = this.birdie.api.destroy_block (user.screen_name);

                if (reply == 0) {
                    this.unblock_button.hide ();
                    this.follow_button.show ();
                    this.block_button.show ();
                }
                return false;
            });

            return null;
        }

        public void set_avatar (string avatar_file) {
            Idle.add(() => {
                this.avatar_img.set_from_file (avatar_file);
                return false;
            });
        }
    }
}
