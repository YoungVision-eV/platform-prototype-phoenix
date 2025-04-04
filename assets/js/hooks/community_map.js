const CommunityMap = {
  mounted() {
    // Load Leaflet CSS
    const leafletCss = document.createElement("link");
    leafletCss.rel = "stylesheet";
    leafletCss.href = "https://unpkg.com/leaflet@1.9.4/dist/leaflet.css";
    leafletCss.integrity =
      "sha256-p4NxAoJBhIIN+hmNHrzRCf9tD/miZyoHS5obTRR9BMY=";
    leafletCss.crossOrigin = "";
    document.head.appendChild(leafletCss);

    // Load Leaflet JS
    const leafletScript = document.createElement("script");
    leafletScript.src = "https://unpkg.com/leaflet@1.9.4/dist/leaflet.js";
    leafletScript.integrity =
      "sha256-20nQCchB9co0qIjJZRGuk2/Z9VM+kNiyxNV1lvTlZBo=";
    leafletScript.crossOrigin = "";

    leafletScript.onload = () => {
      this.initMap();
    };

    document.head.appendChild(leafletScript);
  },

  initMap() {
    // Initialize the map
    this.map = L.map(this.el).setView([51.1657, 10.4515], 10); // Default view centered on Germany

    // Add OpenStreetMap tiles
    L.tileLayer("https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", {
      attribution:
        '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors',
      maxZoom: 19,
    }).addTo(this.map);

    // Add user markers
    this.addUserMarkers();
  },

  addUserMarkers() {
    try {
      const users = JSON.parse(this.el.dataset.users);

      users.forEach((user) => {
        if (user.latitude && user.longitude) {
          // Create a marker for each user with location data
          const marker = L.marker([user.latitude, user.longitude]).addTo(
            this.map
          );

          // Add a popup with user info, profile picture, and link to profile
          marker.bindPopup(`
            <div class="flex items-center mb-2">
              <div class="w-10 h-10 rounded-full overflow-hidden mr-2 flex-shrink-0">
                <img src="${user.profile_picture_url}" 
                     alt="${user.display_name}'s profile picture" 
                     class="w-full h-full object-cover" />
              </div>
              <div>
                <a href="/users/${user.id}" class="font-bold text-orange-600 hover:underline">
                  ${user.display_name}
                </a>
                <p class="text-sm">${user.location}</p>
              </div>
            </div>
          `);
        }
      });

      // If we have users with locations
      if (users.length > 0 && users.some((u) => u.latitude && u.longitude)) {
        const usersWithLocations = users.filter(
          (u) => u.latitude && u.longitude
        );

        if (usersWithLocations.length === 1) {
          // If there's only one marker, center on it but maintain a reasonable zoom level
          const user = usersWithLocations[0];
          this.map.setView([user.latitude, user.longitude], 8); // Zoom level 8 gives a good city/region view
        } else if (usersWithLocations.length > 1) {
          // If there are multiple markers, fit the map to show all of them
          const markers = usersWithLocations.map((u) => [
            u.latitude,
            u.longitude,
          ]);
          this.map.fitBounds(markers);

          // Limit maximum zoom when fitting bounds to avoid excessive zoom
          const currentZoom = this.map.getZoom();
          if (currentZoom > 10) {
            this.map.setZoom(10);
          }
        }
      } else {
        // If no users have locations, keep the default view centered on Germany
        this.map.setView([51.1657, 10.4515], 6);
      }
    } catch (error) {
      console.error("Error parsing user data:", error);
    }
  },
};

export default CommunityMap;
