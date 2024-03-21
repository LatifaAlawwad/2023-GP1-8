import {
    addDoc,
    collection,
    doc,
    getFirestore,
    updateDoc,
    getDoc
} from "https://www.gstatic.com/firebasejs/10.8.0/firebase-firestore.js";
import {
    getDownloadURL,
    getStorage,
    ref,
    uploadBytes
} from "https://www.gstatic.com/firebasejs/10.8.0/firebase-storage.js";
import { initializeApp } from "https://www.gstatic.com/firebasejs/10.8.0/firebase-app.js";




    const firebaseConfig = {
        apiKey: "AIzaSyDror2apOXVOmcr7O3bswc-KhZpBFnmuiw",
        authDomain: "fir-hail-ec5a7.firebaseapp.com",
        projectId: "fir-hail-ec5a7",
        storageBucket: "fir-hail-ec5a7.appspot.com",
        messagingSenderId: "652061667089",
        appId: "1:652061667089:web:1103ef9a5c45ea6d1c26b0",
    };

      const app = initializeApp(firebaseConfig);
        const db = getFirestore(app);
        const storage = getStorage(app);
        const days = ['الأحد', 'الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت'];
        let images = [];

           const uploadInput = document.getElementById('uploadInput');
            const imageContainer = document.getElementById('imageContainer');
    const largeImageContainer = document.createElement('div');
        largeImageContainer.className = 'large-image-container';
        document.body.appendChild(largeImageContainer);

            const urlParams = new URLSearchParams(window.location.search);
            const placeId = urlParams.get("placeId");
            const dbplace = urlParams.get("db");
            console.log("placeId:", placeId);
            console.log("dbplace:", dbplace);

            let placeDocRef = null; // Initialize placeDocRef variable

            if (dbplace == "pending") {
                // Reference to the "PendingPlaces" collection and the specific place document
                const addedPlacesRef = collection(db, 'PendingPlaces');
                placeDocRef = doc(addedPlacesRef, placeId);
            } else {
                // Reference to the "ApprovedPlaces" collection and the specific place document
                const addedPlacesRef = collection(db, 'ApprovedPlaces');
                placeDocRef = doc(addedPlacesRef, placeId);
            }

document.addEventListener("DOMContentLoaded", async () => {
    const placeSnapshot = await getDoc(placeDocRef);
    if (placeSnapshot.exists()) {
        const placeData = placeSnapshot.data();
        const placeNameInput = document.getElementById('placeName');
        const descriptionInput = document.getElementById('description');

        if (placeData) {
            if (placeData.placeName) {
                placeNameInput.value = placeData.placeName;
            }
            if (placeData.description) {
                descriptionInput.value = placeData.description;
            }
            if (placeData.images) {
                placeData.images.forEach(imageUrl => {
                    const imageContainerDiv = createImageContainerDiv(imageUrl, '');
                    imageContainer.prepend(imageContainerDiv);
                    images.push(imageUrl);
                    const uploadArea = document.querySelector('.upload');
                    uploadArea.style.marginLeft = '1%';
                });
            }

            if (placeData.WorkedDays) {
                days.forEach(day => {
                    const dayData = placeData.WorkedDays.find(data => data.day === day);
                    if (dayData) {
                        const t = convertTo24HourFormat(dayData['وقت الإفتتاح']);
                        console.log(t);
                        console.log(convertTo12HourFormat(t));
                        if (dayData['وقت الإفتتاح'] === "00:00 AM" && dayData['وقت الإغلاق'] === "12:59 PM") {
                            addWorkingDayRow(day, '', '', true);
                        } else {
                            addWorkingDayRow(day, dayData['وقت الإفتتاح'], dayData['وقت الإغلاق'], false);
                        }
                    } else {
                        addWorkingDayRow(day, '', '', false);
                    }
                });
            } else {
                days.forEach(day => addWorkingDayRow(day, '', '', false));
            }
        }
    } else {
        console.log("No such place document!");
    }

    uploadInput.addEventListener('change', handleUpload);

    async function handleUpload(event) {
        const files = event.target.files;
        if (files.length === 0) {
            alert("Please select at least one image.");
            return;
        }

        try {
            const uploadTasks = Array.from(files).map(async (imageFile) => {
                const imageUrl = URL.createObjectURL(imageFile);
                const imageContainerDiv = createImageContainerDiv(imageUrl, imageFile.name);
                imageContainer.appendChild(imageContainerDiv);

                moveUploadArea();

                const storageRef = ref(storage, `images/${imageFile.name}`);
                const snapshot = await uploadBytes(storageRef, imageFile);
                const downloadURL = await getDownloadURL(snapshot.ref);
                images.push(downloadURL);
            });

            await Promise.all(uploadTasks);

            uploadInput.value = null;

            updateFirestoreDocument();
        } catch (error) {
            console.error('Error uploading images: ', error);
        }
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
                const index = images.indexOf(imageUrl);
                if (index !== -1) {
                    images.splice(index, 1);
                }
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
            uploadArea.style.marginLeft = 'auto';
            uploadArea.style.marginRight = 'auto';
            imageContainer.appendChild(uploadArea);
        }
    }

    function convertTo24HourFormat(databaseTime) {
        if (databaseTime) {
            const [hours, minutes, ampm] = databaseTime.split(/[:\s]+/);
            const isAM = ampm && ampm.toUpperCase() === 'AM';
            const formattedHours = (isAM ? hours % 12 : (parseInt(hours) % 12) + 12).toString().padStart(2, '0');
            const formattedMinutes = minutes.toString().padStart(2, '0');
            return `${formattedHours}:${formattedMinutes}`;
        }
        return '';
    }

    function addWorkingDayRow(dayName, openingTime, closingTime, switchOn) {
        const tbody = document.querySelector('#workingDaysTable tbody');
        const newRow = tbody.insertRow();

        const closingTimeCell = newRow.insertCell(0);
        const closingInput = document.createElement('input');
        closingInput.type = 'time';
        closingInput.value = convertTo24HourFormat(closingTime);
        closingInput.disabled = switchOn ? true : false;
        closingTimeCell.appendChild(closingInput);

        const openingTimeCell = newRow.insertCell(1);
        const openingInput = document.createElement('input');
        openingInput.type = 'time';
        openingInput.value = convertTo24HourFormat(openingTime);
        openingInput.disabled = switchOn ? true : false;
        openingTimeCell.appendChild(openingInput);

        const switchCell = newRow.insertCell(2);
        const switchLabel = document.createElement('label');
        switchLabel.className = 'switch';
        const switchInput = document.createElement('input');
        switchInput.type = 'checkbox';
        switchInput.className = 'checkbox';
        switchInput.checked = switchOn;
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

    const saveButton = document.getElementById('saveButton');
    saveButton.addEventListener('click', saveChanges);
});

function saveChanges(event) {
    event.preventDefault();
    const confirmation = window.confirm("هل أنت متأكد من حفظ التغييرات؟");
    if (confirmation) {
        updateFirestoreDocument();
    }
}

function getWorkedDays() {
    const workedDays = [];
    document.querySelectorAll('#workingDaysTable tbody tr').forEach(row => {
        const day = row.cells[3].innerText;
        const openingTimeInput = row.cells[1].querySelector('input');
        const closingTimeInput = row.cells[0].querySelector('input');
        let openingTime, closingTime;

        const switchInput = row.cells[2].querySelector('input');
        if (switchInput && switchInput.checked) {
            openingTime = '00:00 AM';
            closingTime = '12:59 PM';
        } else {
            openingTime = convertTo12HourFormat(openingTimeInput.value);
            closingTime = convertTo12HourFormat(closingTimeInput.value);
        }

        if (switchInput && (switchInput.checked || openingTime !== '' || closingTime !== '')) {
            workedDays.push({
                day, 'وقت الإغلاق': closingTime, 'وقت الإفتتاح': openingTime
            });
        }
    });
    return workedDays;
}

function convertTo12HourFormat(timeString) {
    if (!timeString) return '';

    const [hours24, minutes] = timeString.split(':');
    const hours = parseInt(hours24, 10);
    const suffix = hours >= 12 ? 'PM' : 'AM';
    const hours12 = ((hours + 11) % 12 + 1);
    return `${hours12}:${minutes} ${suffix}`;
}

async function updateFirestoreDocument() {
    try {
        console.log('update function called!');
        const updatedPlaceName = document.getElementById('placeName').value;
        const updatedDescription = document.getElementById('description').value;
        const WorkedDays = getWorkedDays();
        const imageUrls = images;

        const updatedData = {
            placeName: updatedPlaceName,
            description: updatedDescription,
            WorkedDays: WorkedDays,
            images: imageUrls // Fixed the key name here
        };

        await updateDoc(placeDocRef, updatedData);
    } catch (error) {
        console.error('Error updating place details in the database: ', error);
    }
}