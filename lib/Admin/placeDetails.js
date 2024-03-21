  // Import the functions you need from the SDKs you need
    import { initializeApp } from "https://www.gstatic.com/firebasejs/9.12.1/firebase-app.js";
    import { getFirestore, doc, collection, getDoc } from "https://www.gstatic.com/firebasejs/9.12.1/firebase-firestore.js";

    document.addEventListener('DOMContentLoaded', async () => {

       const firebaseConfig = {
          apiKey: "AIzaSyBKCStEljQdADcPTDJPG49jPYdj65Ld-aE",
            appId: "1:652061667089:web:1103ef9a5c45ea6d1c26b0",
             messagingSenderId: "652061667089",
           projectId: "fir-hail-ec5a7"
        };


        const app = initializeApp(firebaseConfig);
        const db = getFirestore(app);

        // Get the place ID from the URL
        const urlParams = new URLSearchParams(window.location.search);
        const placeId = urlParams.get("placeId");
        const dbplace = urlParams.get("db");
console.log("placeId:", placeId);
console.log("dbplace:", dbplace);


 let placeDocRef="";
        if (dbplace == "pending"){
        // Reference to the "PendingPlaces" collection and the specific place document
         const addedPlacesRef = collection(db, 'PendingPlaces');
         placeDocRef = doc(addedPlacesRef, placeId);
}else {
// Reference to the "ApprovedPlaces" collection and the specific place document
        const addedPlacesRef = collection(db, 'ApprovedPlaces');
         placeDocRef = doc(addedPlacesRef, placeId);
        }





        // Function to fetch and display place details and images
        const displayPlaceDetails = async () => {
            try {
                const placeDoc = await getDoc(placeDocRef);
                if (placeDoc.exists()) {
                    const placeData = placeDoc.data();
                    const placeName = placeData.placeName;
                    const description = placeData.description;
                    const neighbourhood = placeData.neighbourhood;
                    const city = placeData.city;
                    const category = placeData.category;
                    const WebLink = placeData.WebLink;
                    let hasValet = placeData.hasValetServiced;
                    const images = placeData.images;
                    const latitude = placeData.latitude;
                    const longitude = placeData.longitude;


          if(hasValet== null ){ hasValet='لم يتم التحديد';}else {
             if (!hasValet){hasValet='لا';}else {hasValet='نعم';}  }

let weblinkHtml = '';

if (!WebLink || WebLink === '') {
   weblinkHtml = `<p>
       لم يتم التحديد
        <strong style="color: #1d5011; font-size: 18px; display: inline-block; margin-right: 5px;">:رابط الموقع الإلكتروني</strong>
    </p>`;
} else {
    weblinkHtml = `<p>
        <a href="${WebLink}" style="color: blue; text-decoration: underline;" target="_blank">${WebLink}</a>
        <strong style="color: #1d5011; font-size: 18px; display: inline-block; margin-right: 5px;">:رابط الموقع الإلكتروني</strong>
    </p>`;

}


const workedDaysArray = placeData.WorkedDays;
let workingDaysHTML = '';

if (!workedDaysArray || workedDaysArray.length === 0) {
    workingDaysHTML = '<span>لا توجد ساعات عمل</span>';
} else {
    workingDaysHTML = '<table id="workingDaysTable">';
    workingDaysHTML += '<tr><th>وقت الإغلاق</th><th>وقت الإفتتاح</th><th>اليوم</th></tr>';

    workedDaysArray.forEach((dayObject, index) => {
        const day = dayObject.day;
        const openingTime = dayObject['وقت الإفتتاح'];
        const closingTime = dayObject['وقت الإغلاق'];

        const isOpen24Hours = openingTime === '00:00 AM' && closingTime=== '12:59 PM' ;


        if (isOpen24Hours) {
           workingDaysHTML += `
    <tr>
         <td colspan="2">مفتوح 24 ساعة</td>

        <td>${day}</td>
    </tr>`;
        } else {
            workingDaysHTML += `<tr><td>${closingTime}</td><td>${openingTime}</td><td>${day}</td></tr>`;
        }
    });

    workingDaysHTML += '</table>';
}












if (category == "مراكز تسوق") {
    let INorOUT = placeData.INorOUT;
    let hasFoodCourt = placeData.hasFoodCourt;
    let hasPlayArea = placeData.hasPlayArea;
    let hasSupermarket = placeData.hasSupermarket;
    let hasCinema = placeData.hasCinema;



      if(INorOUT== null ){ INorOUT='لم يتم التحديد';}

    if(hasFoodCourt== null ){ hasFoodCourt='لم يتم التحديد';}else {
if (!hasFoodCourt){hasFoodCourt='لا';}else {hasFoodCourt='نعم';}    }




if(hasPlayArea== null ){ hasPlayArea='لم يتم التحديد';}else {
if (!hasPlayArea){hasPlayArea='لا';}else {hasPlayArea='نعم';}  }




if(hasSupermarket== null ){ hasSupermarket='لم يتم التحديد';}else {
if (!hasSupermarket){hasSupermarket='لا';}else {hasSupermarket='نعم';}}



if(hasCinema== null ){ hasCinema='لم يتم التحديد';}else {
if (!hasCinema){hasCinema='لا';}else {hasCinema='نعم';}   }








let shopOptions = placeData.shopOptions;
let shopOptionsHTML = '';

if (!shopOptions || shopOptions.length === 0) {
    shopOptionsHTML = '<span>لا توجد خيارات للمتجر</span>';
} else {
    shopOptionsHTML = shopOptions.map((item) => `<li style=" font-size: 16px;">${item}<span style="color: #1d5011; font-size: 1.5em;">&bull;</span></li>`).join('');
}







    const placeDetails = document.getElementById('placeDetails');
    placeDetails.innerHTML = `
        <p><span style="color: black; font-size: 16px; margin-right: 5px;">${placeName}</span><strong style="color: #1d5011; font-size: 18px; display: inline-block;">:اسم المكان</strong></p>
        <p>
         <span style="color: black; font-size: 16px; margin-right: 5px;">${city}</span><strong style="color: #1d5011; font-size: 18px; display: inline-block; margin-right:10px;">:الحي</strong>
        <span style="color: black; font-size: 16px; margin-right: 5px;">${neighbourhood}</span><strong style="color: #1d5011; font-size: 18px; display: inline-block; ">:المدينة</strong>
        </p>
        <p><span style="color: black; font-size: 16px; margin-right: 5px;">${category}</span><strong style="color: #1d5011; font-size: 18px; display: inline-block;">:الفئة</strong></p>
         <div style="display: flex; justify-content: flex-end; align-items: baseline;">
    <span style="color: black; font-size: 16px; margin-right: 5px;">${description}</span>
    <strong style="color: #1d5011; font-size: 18px; margin-right: 5px;">:وصف المكان</strong>
    </div>
    ${weblinkHtml}

    <p><span style="color: black; font-size: 16px; margin-right: 5px;"></span><strong style="color: #1d5011; font-size: 18px; display: inline-block;">:ساعات العمل</strong></p>



          ${workingDaysHTML}


<p><span style="color: black; font-size: 16px; margin-right: 5px;"></span><strong style="color: #1d5011; font-size: 18px; display: inline-block;">:خيارات المتجر</strong></p>
    <ul style="list-style-type: none; margin-right: 20px; padding-inline-start: 0;">${shopOptionsHTML}</ul>
        <p><span style="color: black; font-size: 16px; margin-right: 5px;">${hasValet}</span><strong style="color: #1d5011; font-size: 18px; display: inline-block;">:هل توجد خدمة ركن السيارات</strong></p>
        <p><span style="color: black; font-size: 16px; margin-right: 5px;">${hasPlayArea}</span><strong style="color: #1d5011; font-size: 18px; display: inline-block;">:هل توجد منطقة ألعاب</strong></p>
        <p><span style="color: black; font-size: 16px; margin-right: 5px;">${hasFoodCourt}</span><strong style="color: #1d5011; font-size: 18px; display: inline-block;">:هل توجد منطقة مطاعم</strong></p>
        <p><span style="color: black; font-size: 16px; margin-right: 5px;">${hasSupermarket}</span><strong style="color: #1d5011; font-size: 18px; display: inline-block;">:هل توجد سوبرماركت</strong></p>
        <p><span style="color: black; font-size: 16px; margin-right: 5px;">${hasCinema}</span><strong style="color: #1d5011; font-size: 18px; display: inline-block;">:هل يوجد سينما</strong></p>
        <p><span style="color: black; font-size: 16px; margin-right: 5px;">${INorOUT}</span><strong style="color: #1d5011; font-size: 18px; display: inline-block;">:هل المكان داخلي أم خارجي</strong></p>
    `;



initMap(latitude,longitude);






} else if (category == "فعاليات و ترفيه") {

    let isTemporary = placeData.isTemporary;
    const startDate = placeData.startDate;
    const finishDate = placeData.finishDate;
    let INorOUT = placeData.INorOUT;
    const shopOptions=placeData.shopOptions;
    let hasReservation = placeData.hasReservation;
    const reservationDetails = placeData.reservationDetails;
    const typeEnt=placeData.typeEnt;
let hasreservation='';
let istemporary='';
       if(isTemporary== null ){ istemporary='لم يتم التحديد';} else{
if (!isTemporary){istemporary='لا';}else {istemporary='نعم';}}

 if(hasReservation== null ){ hasreservation='لم يتم التحديد';} else{
if (!hasReservation){hasreservation='لا';}else {hasreservation='نعم';} }

   if(INorOUT== null ){ INorOUT='لم يتم التحديد';}




    const placeDetails = document.getElementById('placeDetails');
    placeDetails.innerHTML = `
           <p><span style="color: black; font-size: 16px; margin-right: 5px;">${placeName}</span><strong style="color: #1d5011; font-size: 18px; display: inline-block;">:اسم المكان</strong></p>


 <p>
         <span style="color: black; font-size: 16px; margin-right: 5px;">${city}</span><strong style="color: #1d5011; font-size: 18px; display: inline-block; margin-right:10px;">:الحي</strong>
        <span style="color: black; font-size: 16px; margin-right: 5px;">${neighbourhood}</span><strong style="color: #1d5011; font-size: 18px; display: inline-block; ">:المدينة</strong>
        </p>
        <p><span style="color: black; font-size: 16px; margin-right: 5px;">${category}</span><strong style="color: #1d5011; font-size: 18px; display: inline-block;">:الفئة</strong></p>
          <div style="display: flex; justify-content: flex-end; align-items: baseline;">
    <span style="color: black; font-size: 16px; margin-right: 5px;">${description}</span>
    <strong style="color: #1d5011; font-size: 18px; margin-right: 5px;">:الوصف</strong>
</div>
    ${weblinkHtml}

                 <p><span style="color: black; font-size: 16px; margin-right: 5px;"></span><strong style="color: #1d5011; font-size: 18px; display: inline-block;">:ساعات العمل</strong></p>
         ${workingDaysHTML}

        <p><span style="color: black; font-size: 16px; margin-right: 5px;">${typeEnt}</span><strong style="color: #1d5011; font-size: 18px; display: inline-block;">:نوع الفعالية</strong></p>
        <p><span style="color: black; font-size: 16px; margin-right: 5px;">${istemporary}</span><strong style="color: #1d5011; font-size: 18px; display: inline-block;">:هل الفعالية موقتة</strong></p>
        ${isTemporary ? `<p><span style="color: black; font-size: 16px; margin-right: 5px;">${startDate}</span><strong style="color: #1d5011; font-size: 18px; display: inline-block;">:تاريخ البداية</strong></p>` : ''}
        ${isTemporary ? `<p><span style="color: black; font-size: 16px; margin-right: 5px;">${finishDate}</span><strong style="color: #1d5011; font-size: 18px; display: inline-block;">:تاريخ النهاية</strong></p>` : ''}
        <p><span style="color: black; font-size: 16px; margin-right: 5px;">${INorOUT}</span><strong style="color: #1d5011; font-size: 18px; display: inline-block;">:هل المكان داخلي أم خارجي</strong></p>
                <p><span style="color: black; font-size: 16px; margin-right: 5px;">${hasValet}</span><strong style="color: #1d5011; font-size: 18px; display: inline-block;">:هل توجد خدمة ركن السيارات</strong></p>
        <p><span style="color: black; font-size: 16px; margin-right: 5px;">${hasreservation}</span><strong style="color: #1d5011; font-size: 18px; display: inline-block;">:هل يتطلب حجز</strong></p>
        ${hasReservation ? `<p><span style="color: black; font-size: 16px; margin-right: 5px;">${reservationDetails}</span><strong style="color: #1d5011; font-size: 18px; display: inline-block;">:تفاصيل الحجز</strong></p>` : ''}

    `;


initMap(latitude,longitude);





} else {
    const priceRange = placeData.priceRange;
    const cuisine = placeData.cuisine;
    const atmosphere = placeData.atmosphere;
    const serves = placeData.serves;
    let allowChildren = placeData.allowChildren;
    let hasReservation = placeData.hasReservation;
    const reservationDetails = placeData.reservationDetails;
let hasreservation='';


 if(hasReservation== null ){ hasreservation='لم يتم التحديد';} else{

if (!hasReservation){hasreservation='لا';}else {hasreservation='نعم';} }


  if(allowChildren== null ){ allowChildren='لم يتم التحديد';} else{
if (!allowChildren){allowChildren='لا';}else {allowChildren='نعم';}  }








    const placeDetails = document.getElementById('placeDetails');
    placeDetails.innerHTML = `
         <p><span style="color: black; font-size: 16px; margin-right: 5px;">${placeName}</span><strong style="color: #1d5011; font-size: 18px; display: inline-block;">:اسم المكان</strong></p>


        <p>
         <span style="color: black; font-size: 16px; margin-right: 5px;">${city}</span><strong style="color: #1d5011; font-size: 18px; display: inline-block; margin-right:10px;">:الحي</strong>
        <span style="color: black; font-size: 16px; margin-right: 5px;">${neighbourhood}</span><strong style="color: #1d5011; font-size: 18px; display: inline-block; ">:المدينة</strong>
        </p>
          <p><span style="color: black; font-size: 16px; margin-right: 5px;">${category}</span><strong style="color: #1d5011; font-size: 18px; display: inline-block;">:الفئة</strong></p>
          <div style="display: flex; justify-content: flex-end; align-items: baseline;">
           <span style="color: black; font-size: 16px; margin-right: 5px;">${description}</span>
          <strong style="color: #1d5011; font-size: 18px; margin-right: 5px;">:الوصف</strong>
          </div>
             ${weblinkHtml}

                <p><span style="color: black; font-size: 16px; margin-right: 5px;"></span><strong style="color: #1d5011; font-size: 18px; display: inline-block;">:ساعات العمل</strong></p>
            ${workingDaysHTML}

         <p><span style="color: black; font-size: 16px; margin-right: 5px;">${priceRange}</span><strong style="color: #1d5011; font-size: 18px; display: inline-block;">:نطاق الأسعار</strong></p>
         <p><span style="color: black; font-size: 16px; margin-right: 5px;">${cuisine}</span><strong style="color: #1d5011; font-size: 18px; display: inline-block;">:نوع الطعام</strong></p>
         <p><span style="color: black; font-size: 16px; margin-right: 5px;">${serves}</span><strong style="color: #1d5011; font-size: 18px; display: inline-block;">:الوجبات المقدمة</strong></p>



    <p> <span style="color: black; font-size: 16px;margin-right: 5px; ">${atmosphere}</span><strong style="color: #1d5011; font-size: 18px; display: inline-block; ">:الجو العام</strong></p>
    <p><span style="color: black; font-size: 16px; margin-right: 5px;">${allowChildren}</span><strong style="color: #1d5011; font-size: 18px; display: inline-block;">:هل يسمح بدخول الأطفال</strong></p>
    <p><span style="color: black; font-size: 16px; margin-right: 5px;">${hasValet}</span><strong style="color: #1d5011; font-size: 18px; display: inline-block;">:هل توجد خدمة ركن السيارات</strong></p>
    <p> <span style="color: black; font-size: 16px;margin-right: 5px; ">${hasreservation}</span><strong style="color: #1d5011; font-size: 18px; display: inline-block; ">:هل هناك حجز</strong></p>
     ${hasReservation ? `<p><span style="color: black; font-size: 16px; margin-right: 5px;">${reservationDetails}</span><strong style="color: #1d5011; font-size: 18px; display: inline-block;">:تفاصيل الحجز</strong></p>` : ''}


`;
initMap(latitude,longitude);
}








                    const imageContainer = document.getElementById('imageContainer');
                    imageContainer.innerHTML = ''; // Clear previous images

                      if (images && images.length > 0) {
                images.forEach((imageUrl) => {
                    const image = document.createElement('img');
                    image.src = imageUrl;
                    image.alt = "Place Image";
                    // Set a fixed size for all images
                    image.style.width = "150px";
                    image.style.height = "150px";
                    imageContainer.appendChild(image);
                });
            } else {
                // If no images are available, display a message
                 const noImageMessage = document.createElement('p');
                noImageMessage.textContent = "لا توجد صور لهذا المكان";
                noImageMessage.style.color = "#1d5011";
                noImageMessage.style.textAlign = "center";
                noImageMessage.style.marginLeft = '40%';
                 noImageMessage.style.marginRight = '40%';
                imageContainer.appendChild(noImageMessage);
            }
                } else {
                    console.error('Place not found.');
                }
            } catch (error) {
                console.error('Error getting place details: ', error);
            }
        };










function initMap(latitude, longitude) {
    // Create initial location object
    var initialLocation = { lat: latitude, lng: longitude };

    // Create map centered at the initial location
    var map = new google.maps.Map(document.getElementById('map'), {
        center: initialLocation,
        zoom: 12
    });

    // Create marker at the initial location
    var marker = new google.maps.Marker({
        position: initialLocation,
        map: map,
        draggable: false
    });


     map.addListener('click', function() {
            var url = 'https://www.google.com/maps/search/?api=1&query=' + latitude + ',' + longitude;
            window.open(url, '_blank');
        });


         marker.addListener('click', function() {
                var url = 'https://www.google.com/maps/search/?api=1&query=' + latitude + ',' + longitude;
                window.open(url, '_blank');
            });


}

const imageContainer = document.getElementById('imageContainer');
        const largeImageContainer = document.createElement('div');
        largeImageContainer.className = 'large-image-container';
        document.body.appendChild(largeImageContainer);

    // Add a click event listener to each image
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



        // Call the displayPlaceDetails function to retrieve and display place details with images
        displayPlaceDetails();
    });

