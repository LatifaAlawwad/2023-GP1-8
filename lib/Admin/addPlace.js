import { v4 as uuidv4 } from 'https://cdn.skypack.dev/uuid';
import {
    addDoc,
    collection,

    doc,
    getFirestore,
    updateDoc,   query,  where, getDocs
} from "https://www.gstatic.com/firebasejs/10.8.0/firebase-firestore.js";
import {
    getDownloadURL,
    getStorage,
    ref,
    uploadBytes
} from "https://www.gstatic.com/firebasejs/10.8.0/firebase-storage.js";
import {initializeApp} from "https://www.gstatic.com/firebasejs/10.8.0/firebase-app.js";
 const firebaseConfig = {

     apiKey: "AIzaSyDror2apOXVOmcr7O3bswc-KhZpBFnmuiw",
       authDomain: "fir-hail-ec5a7.firebaseapp.com",
        projectId: "fir-hail-ec5a7",
          storageBucket: "fir-hail-ec5a7.appspot.com",
            messagingSenderId: "652061667089",
              appId: "1:652061667089:web:1103ef9a5c45ea6d1c26b0",
              messagingSenderId: "652061667089",
  };

    const app = initializeApp(firebaseConfig);
    const db = getFirestore(app);
    const storage = getStorage(app);
    const days = ['الأحد', 'الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت'];
    let areasData = [];
    let deletedImageIndexes = [];
    let images = [];
    var latitude ;
    var longitude;
var searchInput = document.querySelector('input[name="search_input"]');
var map;
var marker;
var geocoder;

document.addEventListener("DOMContentLoaded", async () => {
    await fetchAreasData();
    document.getElementById('addPlaceForm').addEventListener('submit', handleSubmit);
    document.getElementById('city').addEventListener('change', updateNeighborhoods);
    document.getElementById('placeType').addEventListener('change', function () {
        loadFormSection(this.value);
    });

    let placeType = document.getElementById('placeType');
    loadFormSection(placeType.value);
    initMap(); // Initialize the map
    var autocomplete = new google.maps.places.Autocomplete(searchInput, {
        componentRestrictions: { country: 'sa' }
    });
    autocomplete.addListener('place_changed', function () {
        var near_place = autocomplete.getPlace();
        if (near_place.geometry) {
            latitude = near_place.geometry.location.lat();
            longitude = near_place.geometry.location.lng();
            console.log("Latitude: " + latitude);
            console.log("Longitude: " + longitude);

            // Update marker position
            var newPosition = { lat: latitude, lng: longitude };
            marker.setPosition(newPosition);
            map.setCenter(newPosition);

            // Reverse geocode to get the address and update the search input
            geocoder.geocode({ 'location': newPosition }, function (results, status) {
                if (status === 'OK') {
                    if (results[0]) {
                        searchInput.value = results[0].formatted_address;
                    } else {
                        console.log('No results found');
                    }
                } else {
                    console.log('Geocoder failed due to: ' + status);
                }
            });
        } else {
            console.log("Location not found");
        }
    });
});

function initMap() {
    var initialLocation = { lat: 24.7136, lng: 46.6753 };
    map = new google.maps.Map(document.getElementById('map'), {
        center: initialLocation,
        zoom: 12
    });

    marker = new google.maps.Marker({
        position: initialLocation,
        map: map,
        draggable: true
    });

    marker.addListener('dragend', function () {
        var newPosition = marker.getPosition();
        latitude=newPosition.lat();
        longitude=newPosition.lng();
        console.log('New position:', newPosition.lat(), newPosition.lng());

        // Reverse geocode to get the address and update the search input
        geocoder.geocode({ 'location': newPosition }, function (results, status) {
            if (status === 'OK') {
                if (results[0]) {
                    searchInput.value = results[0].formatted_address;
                } else {
                    console.log('No results found');
                }
            } else {
                console.log('Geocoder failed due to: ' + status);
            }
        });
    });

    // Initialize the geocoder
    geocoder = new google.maps.Geocoder();
}


    // Function to fetch areas data
    async function fetchAreasData() {
        try {
            const response = await fetch('areas.json');
            areasData = await response.json();
            console.log("Areas Data Fetched Successfully");
            return areasData;
        } catch (error) {
            console.error("Error fetching areas data: ", error);
        }
    }



    function createBasePlaceData(form) {
        const category = form.placeType.value;
        const city = form.city.value;
        const neighbourhood = form.neighbourhood.value;
        const placeName = form.placeName.value;
        const description = form.description.value;
        const WorkedDays = getWorkedDays();
        const WebLink = form.weblink.value;
        const hasValetServicedElement = document.querySelector('input[name="hasValetServiced"]:checked');
        const hasValetServiced = hasValetServicedElement ? !!hasValetServicedElement.value : null;


        return {
            category,
            city,
            neighbourhood,
            placeName,
            description,
            WorkedDays,
            WebLink,
            hasValetServiced,
             images,
            User_id:"Admin",
            longitude,
            latitude,
        };
    }



function validateMandatoryFields(form) {
    const mandatoryFields = ['placeName', 'city', 'neighbourhood', 'placeType', 'description', 'search_input'];
    for (const field of mandatoryFields) {
        if (!form[field].value.trim()) {
            return false;
        }
    }
    return true;
}


  async function handleSubmit(e) {
      e.preventDefault();

      const form = e.target;
      const category = form.placeType.value;
      let placeData = createBasePlaceData(form);


   if (!validateMandatoryFields(form)) {
        alert("يرجى ملء جميع الحقول المطلوبة (*)");
        return; // Stop further execution
    }

    const placeExists = await checkPlaceExists(placeData.placeName, placeData.latitude, placeData.longitude);
  if (placeExists) {
        alert("هذا المكان موجود بالفعل، لا يمكن اضافته مجددا  ");
        return;
    }




      switch(category) {
          case 'مراكز تسوق':
              placeData = {...placeData, ...getMallSpecificData(form)};
              break;
          case 'مطاعم':
              placeData = {...placeData, ...getRestaurantSpecificData(form)};
              break;
          case 'فعاليات و ترفيه':
              placeData = {...placeData, ...getEventSpecificData(form)};
              break;
          default:
              return;
      }

      console.log(placeData);

 try {
         const docRef = await addDoc(collection(db, 'ApprovedPlaces'), placeData);
         console.log("Document written with ID: ", docRef.id);



         const uuid = uuidv4();
       await updateDoc(doc(db, 'ApprovedPlaces', docRef.id), { place_id: uuid });
         alert('تم إضافة المكان بنجاح!');
        // form.reset();
     } catch (error) {
         console.error("Error adding document: ", error);
         alert("Error adding place: " + error.message);
     }
  }

async function checkPlaceExists(placeName, latitude, longitude) {
    const tolerance = 0.0001; // Adjust the tolerance level as needed

    try {
        const q = query(collection(db, 'ApprovedPlaces'), where('placeName', '==', placeName));
        const querySnapshot = await getDocs(q);

        // Iterate through the query snapshot to check for existing places
        for (const doc of querySnapshot.docs) {
            const data = doc.data();
            // Check if the absolute difference between coordinates is within the tolerance level
            if (Math.abs(data.latitude - latitude) < tolerance && Math.abs(data.longitude - longitude) < tolerance) {
                return true; // Place exists
            }
        }
    } catch (error) {
        console.error("Error checking place existence: ", error);
        return false; // Return false on error
    }
    return false; // If no matching place found, return false
}








































    function getMallSpecificData(form) {
      const hasCinemaElement = document.querySelector('input[name="hasCinema"]:checked');
      const hasCinema = hasCinemaElement ? !!hasCinemaElement.value : null;

      const hasFoodCourtElement = document.querySelector('input[name="hasFoodCourt"]:checked');
      const hasFoodCourt = hasFoodCourtElement ? !!hasFoodCourtElement.value : null;

      const hasPlayAreaElement = document.querySelector('input[name="hasPlayArea"]:checked');
      const hasPlayArea = hasPlayAreaElement ? !!hasPlayAreaElement.value : null;

      const hasSupermarketElement = document.querySelector('input[name="hasSupermarket"]:checked');
      const hasSupermarket = hasSupermarketElement ? !!hasSupermarketElement.value : null;

      const INorOUTElement = document.querySelector('input[name="INorOUT"]:checked');
      const INorOUT = INorOUTElement ? INorOUTElement.value : null;
        const shopOptions = getSelectedShopOptions();

        return { hasCinema, hasFoodCourt, hasPlayArea, hasSupermarket, shopOptions, INorOUT };
    }

    function getRestaurantSpecificData(form) {
const allowChildrenElement = document.querySelector('input[name="allowChildren"]:checked');
const allowChildren = allowChildrenElement ? !!allowChildrenElement.value : null;
        const cuisine = getSelectedCuisines();
        const priceRange = form.priceRange.value;
        const serves = getSelectedServes();
        const atmosphere = getSelectedAtmospheres();
const hasReservationElement = document.querySelector('input[name="hasReservation"]:checked');
const hasReservation = hasReservationElement ? !!hasReservationElement.value : null;
        const reservationDetails = form.reservationDetails.value;

        return { allowChildren, cuisine, priceRange, serves, hasReservation, reservationDetails, atmosphere};
    }

    function getEventSpecificData(form) {

        const INorOUTElement = document.querySelector('input[name="INorOUT"]:checked');
              const INorOUT = INorOUTElement ? INorOUTElement.value : null;
const isTemporaryElement = document.querySelector('input[name="isTemporary"]:checked');
const isTemporary = isTemporaryElement ? !!isTemporaryElement.value : null;
        const typeEnt = form.typeEntSelect.value;
        const startDate = form.startDate.value;
        const finishDate = form.finishDate.value;
const hasReservationElement = document.querySelector('input[name="hasReservation"]:checked');
const hasReservation = hasReservationElement ? !!hasReservationElement.value : null;
        const reservationDetails = form.reservationDetails.value;
        return { INorOUT, isTemporary, typeEnt, startDate, finishDate, hasReservation, reservationDetails };
    }

    function updateNeighborhoods() {
        const citySelect = document.getElementById('city');
        let cityCode = 0;
        if (citySelect.value == "الرياض")
        {
            console.log("changing code to 3")
            cityCode = 3;
        }
        if (citySelect.value == "جدة")
        {
            console.log("changing code to 18")

            cityCode = 18;
        }

        const neighborhoodSelect = document.getElementById('neighbourhood');
        const selectedCity = cityCode;

        fetch('areas.json')
            .then(response => response.json())
            .then(data => {
                neighborhoodSelect.innerHTML = '';

                /** @type {AreaData[]} */
                const neighborhoods = data.filter(area => area.city_id === parseInt(selectedCity));

                neighborhoods.forEach(neighborhood => {
                    const option = document.createElement('option');
                    option.value = neighborhood.name_ar;
                    option.textContent = neighborhood.name_ar;
                    neighborhoodSelect.appendChild(option);
                });

                if (!neighborhoods.length) {
                    neighborhoodSelect.innerHTML = '<option value="">اختر الحي</option>';
                }
            })
            .catch(error => console.error('Error fetching areas:', error));
    }

    function loadFormSection(placeType) {
        let filename = '';
        switch(placeType) {
            case 'مراكز تسوق':
                filename = 'malls.html';
                break;
            case 'مطاعم':
                filename = 'restaurants.html';
                break;
            case 'فعاليات و ترفيه':
                filename = 'events.html';
                break;
            default:

                return;
        }

        fetch(filename)
            .then(response => response.text())
            .then(html => {
                document.getElementById('dynamicFormSection').innerHTML = html;
                initializeDynamicForm();
            })
            .catch(err => console.error('Failed to load form section:', err));
    }


  function toggleDateFieldsDisplay() {

      const temporaryYes = document.getElementById('temporaryYes');
      const startDateDiv = document.getElementById('startDateContainer');
      const finishDateDiv = document.getElementById('finishDateContainer');

      // Check if the "Yes" option is checked
      if (temporaryYes.checked) {
          startDateDiv.style.display = 'block';
          finishDateDiv.style.display = 'block';
      } else {
          startDateDiv.style.display = 'none';
          finishDateDiv.style.display = 'none';
      }
  }


   function toggleReservationDetailsFieldDisplay() {
       const reservationYes = document.getElementById('reservationYes');
       const reservationDiv = document.getElementById('reservationDetailsDiv');
       const hasReservation = reservationYes.checked;
       reservationDiv.style.display = hasReservation ? 'block' : 'none';
   }

    function initializeDynamicForm() {
        const servesDiv = document.getElementById('servesDiv');
        const atmosphereDiv = document.getElementById('atmosphereDiv');
        const cuisineDiv = document.getElementById('cuisineDiv');
        const shopDiv = document.getElementById('shopDiv');

      document.querySelectorAll('input[name="isTemporary"]').forEach(radioButton => {
          radioButton.addEventListener('change', function() {

              // Check if the selected option is "Yes"
              if (this.value === 'true') {
                  // Toggle the display of start and end date fields
                  toggleDateFieldsDisplay();
              } else {
                  // If "No" is selected, hide the fields
                  document.getElementById('startDateContainer').style.display = 'none';
                  document.getElementById('finishDateContainer').style.display = 'none';
              }
          });
      });


document.querySelectorAll('input[name="hasReservation"]').forEach(radioButton => {
          radioButton.addEventListener('change', function() {

              if (this.value === 'true') {
                  toggleReservationDetailsFieldDisplay();
              } else {
                   document.getElementById('reservationDetailsDiv').style.display = 'none';

              }
          });
      });



        if (servesDiv) {
            const checkboxes = servesDiv.querySelectorAll('input[type="checkbox"]');
            checkboxes.forEach(checkbox => {
                checkbox.addEventListener('change', updateServesSelections);
            });
            updateServesSelections();
        }

        if (atmosphereDiv) {
            const checkboxes = atmosphereDiv.querySelectorAll('input[type="checkbox"]');
            checkboxes.forEach(checkbox => {
                checkbox.addEventListener('change', updateAtmosphereSelections);
            });
            updateAtmosphereSelections();
        }

        if (cuisineDiv) {
            const checkboxes = cuisineDiv.querySelectorAll('input[type="checkbox"]');
            checkboxes.forEach(checkbox => {
                checkbox.addEventListener('change', updateCuisineSelections);
            });
            updateCuisineSelections();
        }



        if (shopDiv) {
            const checkboxes = shopDiv.querySelectorAll('input[type="checkbox"]');
            checkboxes.forEach(checkbox => {
                checkbox.addEventListener('change', updateShopSelections);
            });
            updateShopSelections();
        }
    }

   function updateServesSelections() {
          const servesDiv = document.getElementById('servesDiv');
          if (servesDiv) {
              const checkboxes = servesDiv.querySelectorAll('input[type="checkbox"]');
              const selectedValues = Array.from(checkboxes)
                  .filter(checkbox => checkbox.checked)
                  .map(checkbox => checkbox.value);
              console.log(selectedValues);
              document.getElementById('serves').value = JSON.stringify(selectedValues);
          }
      }

    function getSelectedServes() {
        const servesDiv = document.getElementById('servesDiv');
        if (servesDiv) {
            const checkboxes = servesDiv.querySelectorAll('input[type="checkbox"]:checked');
            return Array.from(checkboxes).map(checkbox => checkbox.value);
        } else {
            return [];
        }
    }

    function updateAtmosphereSelections() {
        const atmosphereDiv = document.getElementById('atmosphereDiv');
        if (atmosphereDiv) {
            const checkboxes = atmosphereDiv.querySelectorAll('input[type="checkbox"]');
            const selectedValues = Array.from(checkboxes)
                .filter(checkbox => checkbox.checked)
                .map(checkbox => checkbox.value);
            console.log(selectedValues);
            document.getElementById('atmosphere').value = JSON.stringify(selectedValues);
        }
    }


    function getSelectedAtmospheres() {
        const atmosphereDiv = document.getElementById('atmosphereDiv');
        if (atmosphereDiv) {
            const checkboxes = atmosphereDiv.querySelectorAll('input[type="checkbox"]:checked');
            return Array.from(checkboxes).map(checkbox => checkbox.value);
        } else {
            return [];
        }
    }

    function updateCuisineSelections() {
        const cuisineDiv = document.getElementById('cuisineDiv');
        if (cuisineDiv) {
            const checkboxes = cuisineDiv.querySelectorAll('input[type="checkbox"]');
            const selectedValues = Array.from(checkboxes)
                .filter(checkbox => checkbox.checked)
                .map(checkbox => checkbox.value);
            console.log(selectedValues);
            document.getElementById('cuisine').value = JSON.stringify(selectedValues);
        }
    }

    function getSelectedCuisines() {
        const cuisineDiv = document.getElementById('cuisineDiv');
        if (cuisineDiv) {
            const checkboxes = cuisineDiv.querySelectorAll('input[type="checkbox"]:checked');
            return Array.from(checkboxes).map(checkbox => checkbox.value);
        } else {
            return [];
        }
    }



    function updateShopSelections() {
        const shopDiv = document.getElementById('shopDiv');
        if (shopDiv) {
            const checkboxes = shopDiv.querySelectorAll('input[type="checkbox"]');
            const selectedValues = Array.from(checkboxes)
                .filter(checkbox => checkbox.checked)
                .map(checkbox => checkbox.value);
            console.log(selectedValues);
            document.getElementById('shopOptions').value = JSON.stringify(selectedValues);
        }
    }

    function getSelectedShopOptions() {
        const shopDiv = document.getElementById('shopDiv');
        if (shopDiv) {
            const checkboxes = shopDiv.querySelectorAll('input[type="checkbox"]:checked');
            return Array.from(checkboxes).map(checkbox => checkbox.value);
        } else {
            return [];
        }
    }






document.addEventListener("DOMContentLoaded", () => {
    const imageContainer = document.getElementById('imageContainer');
    const uploadInput = document.getElementById('uploadInput');
        const largeImageContainer = document.createElement('div');
        largeImageContainer.className = 'large-image-container';
        document.body.appendChild(largeImageContainer);

    // Add event listener to the upload input
    uploadInput.addEventListener('change', handleUpload);

   async function handleUpload(event) {
       const files = event.target.files;
       if (files.length === 0) {
           alert("Please select at least one image.");
           return;
       }

       // Process each selected file
       for (let i = 0; i < files.length; i++) {
           const imageFile = files[i];
           const imageUrl = URL.createObjectURL(imageFile);
           const imageContainerDiv = createImageContainerDiv(imageUrl, imageFile.name);
           imageContainer.appendChild(imageContainerDiv);

          moveUploadArea();
           try {
               const storageRef = ref(storage, `images/${imageFile.name}`);
               const snapshot = await uploadBytes(storageRef, imageFile);
               const downloadURL = await getDownloadURL(snapshot.ref);
               images.push(downloadURL); // Store the download URL
           } catch (error) {
               console.error('Error uploading image: ', error);
           }
       }

       uploadInput.value = null;

   }

    function createImageContainerDiv(imageUrl, imageName) {
        const imageContainerDiv = document.createElement('div');
        imageContainerDiv.className = 'image-item';
        imageContainerDiv.style.position = 'relative';

        const deleteIcon = document.createElement('span');
        deleteIcon.innerHTML = '<span>×</span>';
        deleteIcon.className = 'delete-icon';
        deleteIcon.style.position = 'absolute';
        deleteIcon.style.top = '5px';
        deleteIcon.style.right = '5px';
        deleteIcon.style.cursor = 'pointer';

        deleteIcon.onclick = () => {
            const confirmation = window.confirm("هل أنت متأكد من حذف الصورة؟");
            if (confirmation) {
                imageContainer.removeChild(imageContainerDiv);

                moveUploadArea();
            }
        };

        const image = document.createElement('img');
        image.src = imageUrl;
        image.alt = imageName;
        image.classList.add('enlargeable');
        image.style.opacity = '1';
        image.style.width = '150px';
        image.style.height = '150px';

        imageContainerDiv.appendChild(deleteIcon);
        imageContainerDiv.appendChild(image);

        return imageContainerDiv;
    }

   imageContainer.addEventListener('click', (event) => {
          if (event.target.tagName === 'IMG') {
              const imageUrl = event.target.src;

              // Create an enlarged image element
              const largeImage = document.createElement('img');
              largeImage.src = imageUrl;
              largeImage.alt = 'Enlarged Image';

              largeImageContainer.innerHTML = '';
              largeImageContainer.appendChild(largeImage);

              largeImageContainer.classList.add('active');
              imageContainer.classList.add('active');
          }
      });

      // Function to hide the enlarged image container when clicked outside
      largeImageContainer.addEventListener('click', () => {
          largeImageContainer.classList.remove('active');
          imageContainer.classList.remove('active');
      });




    function moveUploadArea() {
        const imageItems = document.querySelectorAll('.image-item');
        const uploadArea = document.querySelector('.upload');
        if (imageItems.length > 0) {
            uploadArea.style.marginLeft = '10%';
            uploadArea.style.marginRight = '10%';
            const lastImage = imageItems[imageItems.length - 1];
            lastImage.after(uploadArea);
        } else {
            // If there are no images, place upload area inside the image container
            uploadArea.style.marginLeft = 'auto';
            uploadArea.style.marginRight = 'auto';
            imageContainer.appendChild(uploadArea);
        }
    }
});




























function getWorkedDays() {
    const workedDays = [];
    document.querySelectorAll('#workingDaysTable tbody tr').forEach(row => {
        const day = row.cells[3].innerText;
        const openingTimeInput = row.cells[1].querySelector('input');
        const closingTimeInput = row.cells[0].querySelector('input');
        let openingTime, closingTime;

        // Check if the switch is on
        const switchInput = row.cells[2].querySelector('input');
        if (switchInput && switchInput.checked) {
            openingTime = '00:00 AM';
            closingTime = '12:59 PM';
        } else {
            // Get the opening and closing times from the inputs
            openingTime = convertTo12HourFormat(openingTimeInput.value);
            closingTime = convertTo12HourFormat(closingTimeInput.value);
        }

        // Log extracted data for debugging
        console.log("Day:", day);
        console.log("Opening Time:", openingTime);
        console.log("Closing Time:", closingTime);

        // Only add the day if the switch is off and both opening and closing times are set
        if (switchInput && (switchInput.checked || openingTime !== '' || closingTime !== '')) {
            workedDays.push({
                   day,'وقت الإغلاق':closingTime,'وقت الإفتتاح':openingTime
            });
        }
    });
    return workedDays;
}


































 function convertTo12HourFormat(timeString) {
        if (!timeString) return ''; // Handle undefined or empty string

        const [hours24, minutes] = timeString.split(':');
        const hours = parseInt(hours24, 10);
        const suffix = hours >= 12 ? 'PM' : 'AM';
        const hours12 = ((hours + 11) % 12 + 1); // Convert 0-23 hour to 1-12 format

        return `${hours12}:${minutes} ${suffix}`;
    }


   function addWorkingDayRow(dayName = '', openingTime = '', closingTime = '') {
       const tbody = document.querySelector('#workingDaysTable tbody');
       const newRow = tbody.insertRow();

       const closingTimeCell = newRow.insertCell(0);
       const closingInput = document.createElement('input');
       closingInput.type = 'time';
       closingInput.value = closingTime;
       closingInput.disabled = true;
       closingTimeCell.appendChild(closingInput);

       const openingTimeCell = newRow.insertCell(1);
       const openingInput = document.createElement('input');
       openingInput.type = 'time';
       openingInput.value = openingTime;
       openingInput.disabled = true;
       openingTimeCell.appendChild(openingInput);

       const switchCell = newRow.insertCell(2);
       const switchLabel = document.createElement('label');
       switchLabel.className = 'switch';
       const switchInput = document.createElement('input');
       switchInput.type = 'checkbox'; // Changed to checkbox
       switchInput.className = 'checkbox';
       switchInput.checked = true;
       switchLabel.appendChild(switchInput);
       const switchSlider = document.createElement('span');
       switchSlider.className = 'slider round';
       switchLabel.appendChild(switchSlider);
       switchCell.appendChild(switchLabel);

       const dayCell = newRow.insertCell(3);
       dayCell.textContent = dayName;

       switchInput.addEventListener('change', function () {
           const isEnabled = !this.checked;
           closingInput.disabled = !isEnabled;
           openingInput.disabled = !isEnabled;
       });
   }



    updateNeighborhoods();
    days.forEach(day => addWorkingDayRow(day));
