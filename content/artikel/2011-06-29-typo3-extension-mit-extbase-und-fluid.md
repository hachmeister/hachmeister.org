+++
title = "Typo3 Extension mit Extbase und Fluid"
description = "Erstellung einer Typo3 Extension mit dem Extbase MVC-Framework und dem Fluid Templating System. Anhand einer sehr einfachen Bildergalerie zeige ich wie man mit Extbase und Fluid eine Typo3 Extension erstellen kann."
date = 2011-06-29

aliases = [
    '/2011/06/typo3-extension-mit-extbase-und-fluid',
    '/artikel/webentwicklung/typo3-extension-mit-extbase-und-fluid',
]
+++
Es werden nur ein paar grundlegende Bausteine in diesem Tutorial erklärt. Dazu zählen die Repository bzw. Model Klassen des Extbase Systems sowie einfache Templates mit dem Fluid System.

Verwendete Versionen:

-   Typo3 4.5.3
-   Extbase 1.3.0
-   Fluid 1.3.0

In dem Ordner `typo3conf/ext` erstellt man ein Verzeichnis `image_gallery` mit folgenden Unterordnern:

Verzeichnisstruktur der Extension:

```
image_gallery
+-- Classes
| +-- Controller
| +-- Domain
|   +-- Model
|   +-- Repository
+-- Configuration
| +-- TCA
| +-- TypoScript
| +-- DefaultStyles
+-- Resources
  +-- Private
  | +-- Language
  | +-- Layouts
  | +-- Templates
  |   +-- Image
  +-- Public
    +-- Css
    +-- Icons
```

Direkt in dem Ordner `image_gallery` muss für jede Extension eine grundlegende Konfiguration (`ext_emconf.php`) abgelegt werden. Diese enthält Angaben über den Titel der Extension, der Version, die Autorenangaben und auch Abhängigkeiten von anderen Extensions. In diesem Fall ist unsere kleine Bildergalerie abhängig von den beiden Extensions extbase und fluid.

```php
<?php
$EM_CONF[$_EXTKEY] = array(
     'title' => 'Image Gallery',
     'description' => 'A simple image gallery.',
     'category' => 'plugin',
     'author' => 'Karsten Hachmeister',
     'author_email' => 'webmaster@hachmeister.org',
     'dependencies' => 'extbase,fluid',
     'uploadfolder' => 1,
     'clearCacheOnLoad' => 1,
     'version' => '0.0.0',
     'constraints' => array(
       'depends' => array(
         'extbase' => '',
         'fluid' => '',
     ),
   ),
);
```

Die beiden Dateien `ext_localconf.php` und `ext_tables.php` sind entscheidend für die Ausführung der Extension. `ext_localconf.php` wird sowohl im Frontend als auch im Backend geladen, `ext_tables.php` wird nur im Backend geladen.

Die Methode `configurePlugin` fügt dem Typo3 System ein Stück generiertes Typoscript hinzu, dass den Dispatcher des Extbase Systems einbindet und ihn für diese Extension konfiguriert.

In dem Array werden einem Controller Actions zugewiesen. In diesem Fall wäre `Image` der Controller Name und `index` sowie `show` die Actions.

Die Datei `ext_localconf.php`:

```php
<?php
if (!defined('TYPO3_MODE')) {
  die ('Access denied.');
}

Tx_Extbase_Utility_Extension::configurePlugin(
  $_EXTKEY,
  'Pi1',
  array(
    'Image' => 'index,show'
  )
);
```

Die Methode `registerPlugin` fügt die Extension in das Typo3 System, zur Nutzung im Backend, ein.

Hier wird die Extension auch im TCA (Table Configuration Array) eingebunden. Diese Informationen werden verwendet, um Typo3 zu sagen, in welchen Spalten dieser Tabelle die relevanten Informationen für Typo3 gespeichert werden.

Z.B. wird mit dem `label` Eintrag angegeben, dass die Spalte `title` zur Anzeige für einen Datensatz verwendet werden soll.

Eine komplette Auflistung aller möglichen Angaben kann man der Table Configuration Array Referenz entnehmen.

Die Datei `ext_tables.php`:

```php
<?php
if (!defined('TYPO3_MODE')) {
  die ('Access denied.');
}

Tx_Extbase_Utility_Extension::registerPlugin(
  $_EXTKEY,
  'Pi1',
  'Image Gallery'
);

$TCA['tx_imagegallery_domain_model_image'] = array (
  'ctrl' => array (
    'title' => 'LLL:EXT:image_gallery/Resources/Private/Language/locallang_db.xml:tx_imagegallery_domain_model_image',
    'label' => 'title',
    'tstamp' => 'tstamp',
    'crdate' => 'crdate',
    'cruser_id' => 'cruser_id',
    'sortby' => 'sorting',
    'delete' => 'deleted',
    'enablecolumns' => array (
    'disabled' => 'hidden',
  ),
  'dynamicConfigFile' => t3lib_extMgm::extPath($_EXTKEY) . 'Configuration/TCA/tca.php',
  'iconfile' => t3lib_extMgm::extRelPath($_EXTKEY) . 'Resources/Public/Icons/icon_tx_imagegallery_domain_model_image.gif'
  ),
);

t3lib_extMgm::allowTableOnStandardPages('tx_imagegallery_domain_model_image');
t3lib_extMgm::addStaticFile($_EXTKEY, 'Configuration/TypoScript/DefaultStyles', 'ImageGallery CSS Styles (optional)');
```

In der Datei `tca.php` wird das TCA Array weiter geführt. Diese Informationen werden dazu verwendet um Formulare zu generieren, mit denen sich die Datensätze erstellen und bearbeiten lassen. Auch hier gibt es den Verweis auf die Table Configuration Array Referenz.

Die Datei `Configuration/TCA/tca.php`:

```php
<?php
if (!defined('TYPO3_MODE')) {
  die ('Access denied.');
}

$TCA['tx_imagegallery_domain_model_image'] = array (
  'ctrl' => $TCA['tx_imagegallery_domain_model_image']['ctrl'],
  'interface' => array (
    'showRecordFieldList' => 'hidden,title,image'
  ),
  'feInterface' => $TCA['tx_imagegallery_domain_model_image']['feInterface'],
  'columns' => array (
    'hidden' => array (
      'exclude' => 1,
      'label' => 'LLL:EXT:lang/locallang_general.xml:LGL.hidden',
      'config' => array (
        'type' => 'check',
        'default' => '0'
      )
    ),
    'title' => array (
      'exclude' => 0,
      'label' => 'LLL:EXT:image_gallery/Resources/Private/Language/locallang_db.xml:tx_imagegallery_domain_model_image.title',
      'config' => array (
        'type' => 'input',
        'size' => '30',
        'eval' => 'required',
      )
    ),
    'image' => array (
      'exclude' => 0,
      'label' => 'LLL:EXT:image_gallery/Resources/Private/Language/locallang_db.xml:tx_imagegallery_domain_model_image.image',
      'config' => array (
        'type' => 'group',
        'internal_type' => 'file',
        'allowed' => $GLOBALS['TYPO3_CONF_VARS']['GFX']['imagefile_ext'],
        'max_size' => $GLOBALS['TYPO3_CONF_VARS']['BE']['maxFileSize'],
        'uploadfolder' => 'uploads/tx_imagegallery',
        'show_thumbs' => 1,
        'size' => 1,
        'minitems' => 0,
        'maxitems' => 1,
      )
    ),
  ),
  'types' => array (
    '0' => array('showitem' => 'hidden;;1;;1-1-1, title;;;;2-2-2, image;;;;3-3-3')
  ),
  'palettes' => array (
    '1' => array('showitem' => '')
  )
);
```

Das SQL Schema für die Extension um die Bilder in die Datenbank einzufügen. Alle Spalten von `uid` bis hin zu `hidden` sind Spalten, die Typo3 zur Verwaltung braucht. Es gibt noch weitere, es müssen aber nicht immer alle verwendet werden. Diese Spalten wurden auch in der Datei `ext_tables.php` für Typo3 konfiguriert, so dass das System weiß, in welcher Spalte welche Information enthalten ist.

Die Datei `ext_tables.sql`:

```sql
#
# Table structure for table 'tx_imagegallery_domain_model_image'
#
CREATE TABLE tx_imagegallery_domain_model_image (
  uid int(11) NOT NULL auto_increment,
  pid int(11) DEFAULT '0' NOT NULL,
  tstamp int(11) DEFAULT '0' NOT NULL,
  crdate int(11) DEFAULT '0' NOT NULL,
  cruser_id int(11) DEFAULT '0' NOT NULL,
  sorting int(10) DEFAULT '0' NOT NULL,
  deleted tinyint(4) DEFAULT '0' NOT NULL,
  hidden tinyint(4) DEFAULT '0' NOT NULL,

  title tinytext,
  image text,

  PRIMARY KEY (uid),
  KEY parent (pid)
);
```

Die Datei `locallang_db.xml` enthält alle Begriffe, die für das Backend übersetzt werden müssen um in unterschiedlichen Sprachversionen von Typo3 korrekt dargestellt werden zu können. Diese Begriffe werden hier im Beispiel in dem TCA verwendet.

Die default Sprache ist immer Englisch, in diesem Beispiel wurde nur noch Deutsch hinzugefügt, es sind natürlich auch weitere Sprachen möglich.

Die Datei `Resources/Private/Language/locallang_db.xml`:

```xml
<?xml version="1.0" encoding="utf-8" standalone="yes" ?>
<T3locallang>
  <meta type="array">
    <type>database</type>
    <description>Language labels for database tables/fields belonging to extension 'image_gallery'</description>
  </meta>
  <data type="array">
    <languageKey index="default" type="array">
      <label index="tx_imagegallery_domain_model_image">Image</label>
      <label index="tx_imagegallery_domain_model_image.title">Title</label>
      <label index="tx_imagegallery_domain_model_image.image">Image</label>
    </languageKey>
    <languageKey index="de" type="array">
      <label index="tx_imagegallery_domain_model_image">Bild</label>
      <label index="tx_imagegallery_domain_model_image.title">Titel</label>
      <label index="tx_imagegallery_domain_model_image.image">Bild</label>
    </languageKey>
  </data>
</T3locallang>
```

Das Model für die Bilder Datensätze. Models müssen immer von der Klasse `Tx_Extbase_DomainObject_AbstractEntity` angeleitet werden. Dieses Model enthält nur die beiden Attribute `title` und `image`, die den Titel des Bildes und den Dateipfad zu dem Bild enthalten.

Die Getter und Setter sind mitels CamelCase aus dem Spaltennamen zu bilden. Für eine Spalte namens `title` müssen sie `getTitle()` bzw. `setTitle()` heißen und für eine Spalte namens `user_name` müssen sie `getUserName()` bzw. `setUserName()` genannt werden.

Die Datei `Classes/Domain/Model/Image.php`:

```php
<?php
/**
* The image model
*/
class Tx_ImageGallery_Domain_Model_Image extends Tx_Extbase_DomainObject_AbstractEntity {

  /**
  * The image title.
  * @var string
  */
  protected $title = '';

  /**
  * The image file.
  * @var string
  */
  protected $image = '';

  /**
  * Gets the image title.
  * @return string The image title
  */
  public function getTitle() {
    return $this->title;
  }

  /**
  * Sets the image title.
  * @param string $title The image title
  * @return void
  */
  public function setTitle($title) {
    $this->title = $title;
  }

  /**
  * Gets the image file.
  * @return string The image title
  */
  public function getImage() {
    return $this->image;
  }

  /**
  * Sets the image file.
  * @param string $image The image file
  * @return void
  */
  public function setFile($image) {
    $this->image = $image;
  }

}
```

DAO Klassen werden in dem Extbase System von der `Tx_Extbase_Persistence_Repository` Klasse abgeleitet. Standardmäßig bringt diese Klasse schon die wichtigsten Methoden mit um die Datenbank zu manipulieren. Zu nennen wären hier vor allem `add($object)`, `update($object)`, `remove($object)`, `findAll()` sowie `findByUid($uid)`.

Die Datei `Classes/Domain/Repository/ImageRepository.php`:

```php
<?php
/**
* The image repository
*/
class Tx_ImageGallery_Domain_Repository_ImageRepository extends Tx_Extbase_Persistence_Repository {

  /**
  * Finds all images by pid
  *
  * @param int $pid The pid to search for images in
  * @return Tx_Extbase_Persistence_QueryResultInterface The images
  */
  public function findAllByPid($pid) {
    $query = $this->createQuery();
    $query->getQuerySettings()->setStoragePageIds(array($pid));
    return $query->execute();
  }

}
```

Controller Klassen werden von `Tx_Extbase_MVC_Controller_ActionController` abgeleitet. Hier werden die beiden Methoden `indexAction()` und `showAction()` definiert, die in der `configurePlugin()` Methode von oben angegeben wurden.

Die Datei `Classes/Controller/ImageController.php`

```php
<?php
/**
* The image controller
*/
class Tx_ImageGallery_Controller_ImageController extends Tx_Extbase_MVC_Controller_ActionController {

  /**
  * The image repository.
  *
  * @var Tx_ImageGallery_Domain_Model_ImageRepository
  */
  protected $imageRepository;

  /**
  * Dependency injection of the image repository.
  *
  * @param Tx_ImageGallery_Domain_Repository_ImageRepository $imageRepository
  * @return void
  */
  public function injectImageRepository(Tx_ImageGallery_Domain_Repository_ImageRepository $imageRepository) {
    $this->imageRepository = $imageRepository;
  }

  /**
  * Index action for this controller.
  *
  * @return void
  */
  public function indexAction() {
    $images = $this->imageRepository->findAllByPid($GLOBALS["TSFE"]->id);
    $imagesCount = $images->count();
    $rowsCount = ($imagesCount % 3 == 0) ? $imagesCount / 3 : intval($imagesCount / 3) + 1;
    $rows = array();

    for ($i = 0; $i < $rowsCount; $i++) {
      $row = array();

      for ($j = 0; $j < 3; $j++) {
        if ($images->valid()) {
          $row[] = $images->current();
          $images->next();
        } else {
          $row[] = null;
        }
      }

      $rows[] = $row;
    }

    $this->view->assign('rows', $rows);
  }

  /**
  * Show action for this controller.
  *
  * @param int $id The uid of the image.
  * @return void
  */
  public function showAction($id) {
    $this->view->assign('image', $this->imageRepository->findByUid($id));
  }

}
```

Templates in dem Fluid System sind auch vererbbar. In der Datei default.html wird das grundlegende Template definiert. Der Bereich `<f:render section="content" />` wird durch ein vererbtes Templates ersetzt.

Die Datei `Resources/Private/Layouts/default.html`:

```html
<div class="tx-imagegallery">
 <f:render section="content" />
</div>
```

Das Template um die Bilderübersicht darzustellen. Mit `<f:layout name="default" />` wird das übergeordnete Template angegeben.

Die Datei `Resources/Private/Templates/Image/index.html`:

```html
<f:layout name="default" />

<f:section name="content">
  <h1>Image Gallery</h1>
  <table cellspacing="0" cellpadding="0" border="0">
    <f:for each="{rows}" as="images">
      <tr>
        <f:for each="{images}" as="image">
          <td>
            <f:if condition="{image}">
            <f:then>
              <f:link.action action="show" arguments="{id : image}">
              <img src="<f:uri.image src='uploads/tx_imagegallery/{image.image}' width='160' />" />
              </f:link.action>
              <div class="title">{image.title}</div>
              </f:then>
              <f:else>
              &nbsp;
            </f:else>
            </f:if>
          </td>
        </f:for>
      </tr>
    </f:for>
  </table>
</f:section>
```

Das Template zur Darstellung eines einzelnen Bilder, wie oben auch wird hier vom `default.html` Template geerbt.

Die Datei `Resources/Private/Templates/Image/show.html`:

```html
<f:layout name="default" />

<f:section name="content">
  <h1>{image.title}</h1>
  <p><img src="<f:uri.image src='uploads/tx_imagegallery/{image.image}' width='540' />" /></p>
</f:section>
```

Und noch etwas CSS um alles etwas hübscher zu machen.

Die Datei `Resources/Public/Css/ImageGallery.css`:

```css
.tx-imagegallery table { margin-bottom: 20px; width: 100%; }
.tx-imagegallery table td {
  padding: 10px 0; width: 33%; text-align: center;
  vertical-align: top;
}
.tx-imagegallery table td a { border: 0; }
.tx-imagegallery table td img { border: 5px solid #CCC; }
.tx-imagegallery table td .title { margin-top: 4px; }
```

![](../image-gallery.png)

![](../image-gallery-details.png)

Nach dem Einbinden der Extension in das Typo3 System sollte man etwas ähnliches wie oben auf den Bildern gezeigt sehen können.
