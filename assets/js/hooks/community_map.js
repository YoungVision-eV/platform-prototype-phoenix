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

    // Load MarkerCluster CSS
    const markerClusterCss = document.createElement("link");
    markerClusterCss.rel = "stylesheet";
    markerClusterCss.href =
      "https://unpkg.com/leaflet.markercluster@1.4.1/dist/MarkerCluster.css";
    document.head.appendChild(markerClusterCss);

    const markerClusterDefaultCss = document.createElement("link");
    markerClusterDefaultCss.rel = "stylesheet";
    markerClusterDefaultCss.href =
      "https://unpkg.com/leaflet.markercluster@1.4.1/dist/MarkerCluster.Default.css";
    document.head.appendChild(markerClusterDefaultCss);

    // Load Leaflet JS
    const leafletScript = document.createElement("script");
    leafletScript.src = "https://unpkg.com/leaflet@1.9.4/dist/leaflet.js";
    leafletScript.integrity =
      "sha256-20nQCchB9co0qIjJZRGuk2/Z9VM+kNiyxNV1lvTlZBo=";
    leafletScript.crossOrigin = "";

    // Load MarkerCluster JS after Leaflet is loaded
    leafletScript.onload = () => {
      const markerClusterScript = document.createElement("script");
      markerClusterScript.src =
        "https://unpkg.com/leaflet.markercluster@1.4.1/dist/leaflet.markercluster.js";
      markerClusterScript.onload = () => {
        this.initMap();
      };
      document.head.appendChild(markerClusterScript);
    };

    document.head.appendChild(leafletScript);
  },

  initMap() {
    // Initialize the map
    this.map = L.map(this.el, {
      zoom: 5,
      center: [51.1657, 10.4515],
      maxBounds: L.latLngBounds([47.1657, 5.4515], [55.1657, 15.4515]),
    }); // Default view centered on Germany

    // Add OpenStreetMap tiles
    L.tileLayer("https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", {
      attribution:
        '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors',
      maxZoom: 19,
    }).addTo(this.map);

    // Create marker cluster groups
    this.clusterGroup = L.markerClusterGroup();

    // Add cluster groups to map
    this.map.addLayer(this.clusterGroup);

    this.addEventMarkers();
    this.addUserMarkers();
  },

  addEventMarkers() {
    let events = [];
    try {
      events = JSON.parse(this.el.dataset.events);
    } catch (error) {
      console.error("Error parsing event data:", error);
    }

    events.forEach((event) => {
      if (event.latitude && event.longitude) {
        // Create a marker for each event with location data
        const marker = L.marker([event.latitude, event.longitude], {
          icon: L.divIcon({
            className: "bg-red-500 rounded-full w-4 h-4",
          }),
        });

        // Add a popup with event info
        marker.bindPopup(`
            <div class="flex items-center mb-2">
              <div>
                <a href="/community/calendar/${
                  event.id
                }" class="font-bold text-orange-600 hover:underline">
                  ${event.title}
                </a>
                <p class="text-sm">${event.location}</p>
                <p class="text-xs mt-1">
                  <strong>Start:</strong> ${new Date(
                    event.start_time
                  ).toLocaleString()}<br>
                  <strong>End:</strong> ${new Date(
                    event.end_time
                  ).toLocaleString()}
                </p>
              </div>
            </div>
          `);

        // Add marker to cluster group instead of directly to map
        this.clusterGroup.addLayer(marker);
      }
    });
  },

  addUserMarkers() {
    let users = [];
    try {
      users = JSON.parse(this.el.dataset.users);
    } catch (error) {
      console.error("Error parsing user data:", error);
    }

    users.forEach((user) => {
      if (user.latitude && user.longitude) {
        // Create a marker for each user with location data
        const marker = L.marker([user.latitude, user.longitude], {
          icon: L.divIcon({
            className: "bg-blue-500 rounded-full w-4 h-4",
          }),
        });

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

        // Add marker to cluster group instead of directly to map
        this.clusterGroup.addLayer(marker);
      }
    });
  },
};

export default CommunityMap;
