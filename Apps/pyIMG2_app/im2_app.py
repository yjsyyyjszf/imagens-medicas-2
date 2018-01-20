# -*- coding: utf-8 -*-
# ------------------------------------------------------------------------------
# FEDERAL UNIVERSITY OF UBERLANDIA
# Faculty of Electrical Engineering
# Biomedical Engineering Lab
# ------------------------------------------------------------------------------
# Author: Italo Gustavo Sampaio Fernandes
# Contact: italogsfernandes@gmail.com
# Git: www.github.com/italogfernandes
# ------------------------------------------------------------------------------
# Description:
# ------------------------------------------------------------------------------
import sys
# ------------------------------------------------------------------------------
# PyQt5
# from PyQt5.QtWidgets import *
# from views import base_qt5 as base
# PyQt4
from PyQt4.QtGui import *
from views import base_qt4 as base
from controllers import image_handler as ih
# ------------------------------------------------------------------------------
from matplotlib.figure import Figure
from matplotlib.backends.backend_qt4agg import FigureCanvasQTAgg as FigureCanvas
from matplotlib.backends.backend_qt4agg import NavigationToolbar2QT as NavigationToolbar
# ------------------------------------------------------------------------------
import numpy as np  # Images are handled as nparray
import matplotlib.pyplot as plt  # Showing images
from scipy import misc  # Opening images
# ------------------------------------------------------------------------------
sys.path.append('../../toolbox/python')
import scipy_toolbox  # Custom toolbox with image processing functions
# ------------------------------------------------------------------------------


class IM2APP(QMainWindow, base.Ui_MainWindow):
    def __init__(self, parent=None):
        super(IM2APP, self).__init__(parent)
        self.setupUi(self)
        # region Initializing the attributes
        self.my_history = []
        self.noise_params = dict()
        self.noise_amount = 0
        self.filter_params = dict()
        self.filter_size = 0
        # endregion
        # region Images and Matplotlib Figures
        self.original_image = np.ones((100, 100), dtype=np.uint8)*127
        self.edited_image = np.copy(self.original_image)
        self.original_image_fig = Figure(figsize=(0.1, 0.1))
        self.original_image_canvas = FigureCanvas(self.original_image_fig)
        self.edited_image_fig = Figure(figsize=(0.1, 0.1))
        self.edited_image_canvas = FigureCanvas(self.edited_image_fig)
        self.edited_image_toolbar = NavigationToolbar(self.edited_image_canvas, self, coordinates=True)
        # endregion
        # region Ui setup
        self.pos_setup_ui()
        self.setup_signals_connections()
        self.pos_signals_ui()
        # endregion

    # region UI SETUP
    def replace_ui_widgets(self):
        self.statusbar.hide()

        self.v_layout_edited_image.removeWidget(self.replace_edited_image)
        self.h_layout_original_image.removeWidget(self.replace_original_image)
        self.replace_edited_image.setParent(None)
        self.replace_original_image.setParent(None)

        self.original_image_canvas.setSizePolicy(QSizePolicy.Minimum, QSizePolicy.MinimumExpanding)
        self.original_image_canvas.updateGeometry()
        self.h_layout_original_image.addWidget(self.original_image_canvas)
        self.original_image_canvas.draw()

        self.edited_image_canvas.setSizePolicy(QSizePolicy.Expanding, QSizePolicy.Expanding)
        self.edited_image_canvas.updateGeometry()
        self.v_layout_edited_image.addWidget(self.edited_image_canvas)
        self.edited_image_canvas.draw()
        self.v_layout_edited_image.addWidget(self.edited_image_toolbar)

    def pos_setup_ui(self):
        self.replace_ui_widgets()
        self.update_original_figure()
        self.update_edited_figure()
        self.sl_filter_size.setRange(1, 50)
        self.sl_noise_amount.setRange(0, 1000)
        self.cb_noise.addItems(scipy_toolbox.noise_names)
        self.cb_filter.addItems(scipy_toolbox.filter_names)

    def pos_signals_ui(self):
        self.cb_noise.setCurrentIndex(1)
        self.cb_filter.setCurrentIndex(1)

    def setup_signals_connections(self):
        self.cb_noise.currentIndexChanged.connect(self.cb_noise_changed)
        self.cb_filter.currentIndexChanged.connect(self.cb_filter_changed)
        self.sl_noise_amount.valueChanged.connect(self.sl_noise_amount_changed)
        self.sl_filter_size.valueChanged.connect(self.sl_filter_size_changed)
        self.btn_insert_noise.clicked.connect(self.btn_noise_clicked)
        self.btn_insert_filter.clicked.connect(self.btn_insert_filter_clicked)
        self.btn_equalize.clicked.connect(self.btn_equalize_clicked)
        self.radio_compare.clicked.connect(self.radio_compare_clicked)
        self.radio_hist.clicked.connect(self.radio_hist_clicked)
        self.actionAbrir.triggered.connect(self.action_open_triggered)
        self.actionReset.triggered.connect(self.action_reset_triggered)
        self.menuSobre.addAction('&About', self.about)
    # endregion

    # region Interface Slots
    # region Basics Menu
    def cb_img_format_changed(self):
        pass

    def btn_apply_img_format_clicked(self):
        pass

    def sl_brightness_value_changed(self):
        pass

    def btn_apppy_brightness_clicked(self):
        pass

    def sl_contrast_value_changed(self):
        pass

    def btn_apply_contrast_clicked(self):
        pass
    # endregion

    # region Noise Menu
    def cb_noise_changed(self):
        noise_type = str(self.cb_noise.currentText())
        self.lbl_noise.setText('Ruído: ' + noise_type)
        self.noise_params = scipy_toolbox.noise_params[noise_type].copy()
        self.noise_amount = self.noise_params.pop('amount')
        self.lbl_noise_amount.setText('Multiplier: %.3f' % self.noise_amount)
        self.sl_noise_amount.setValue(self.noise_amount*1000)
        self.lbl_noise_params.setText('Params: %s' %
                                      ', '.join([str(p) for p in self.noise_params.keys()]))
        self.edit_noise_params.setText(', '.join([str(p) for p in self.noise_params.values()]))

    def sl_noise_amount_changed(self):
        self.noise_amount = self.sl_noise_amount.value() / 1000.0
        self.lbl_noise_amount.setText('Multiplier: %.3f' % self.noise_amount)

    def btn_noise_clicked(self):
        keys = self.lbl_noise_params.text().split(': ')
        if len(keys) > 1:
            keys = [k for k in keys[1].split(', ')]
        else:
            keys = []

        values = [float(param) for param in self.edit_noise_params.text().split(', ')]

        keys.append('amount')
        values.append(self.sl_noise_amount.value() / 1000.0)

        d = {}
        for i in range(len(keys)):
            d[keys[i]] = values[i]
        print(d)
        mod = ih.NoiseModifier(self.cb_noise.currentText(), d)
        self.edited_image = mod.apply_modifier(self.edited_image)
        self.update_edited_figure()
    # endregion

    # region Filter Menu
    def cb_filter_changed(self):
        filter_type = str(self.cb_filter.currentText())
        self.lbl_filter.setText('Filtro: ' + filter_type)
        self.filter_params = scipy_toolbox.filter_params[filter_type].copy()
        if 'size' in self.filter_params.keys():
            self.lbl_filter_size.show()
            self.sl_filter_size.show()
            self.filter_size = self.filter_params.pop('size')
            self.lbl_filter_size.setText('Size(px): %d' % self.filter_size)
            self.sl_filter_size.setValue(self.filter_size)
        else:
            self.lbl_filter_size.hide()
            self.sl_filter_size.hide()

        if not self.filter_params == {}:
            self.lbl_filter_params.show()
            self.edit_filter_params.show()
            self.lbl_filter_params.setText('Params: %s' % ', '.join([str(p) for p in self.filter_params.keys()]))
            self.edit_filter_params.setText(', '.join([str(p) for p in self.filter_params.values()]))
        else:
            self.lbl_filter_params.hide()
            self.edit_filter_params.hide()

    def sl_filter_size_changed(self):
        self.filter_size = self.sl_filter_size.value()
        self.lbl_filter_size.setText('Size(px): %d' % self.filter_size)

    def btn_insert_filter_clicked(self):
        keys = []
        values = []
        if not self.lbl_filter_params.isHidden():
            keys = self.lbl_filter_params.text().split(': ')
            if len(keys) > 1:
                keys = [k for k in keys[1].split(', ')]
            else:
                keys = []
            values = [float(param) for param in self.edit_filter_params.text().split(', ')]

        if not self.sl_filter_size.isHidden():
            keys.append('size')
            values.append(self.sl_filter_size.value())

        d = {}
        for i in range(len(keys)):
            d[keys[i]] = values[i]

        mod = ih.FilterModifier(self.cb_filter.currentText(), d)
        self.edited_image = mod.apply_modifier(self.edited_image)
        self.update_edited_figure()
    # endregion

    # region Mathematical Morphologies Menu
    def cb_morph_type_changed(self):
        pass

    def radio_morph_binary_gray_toggled(self):
        pass

    def sl_morph_size_value_changed(self):
        pass

    def btn_apply_morph_clicked(self):
        pass
    # endregion

    # region Segmentation Menu
    def sl_segmentation_threshold_value_changed(self):
        pass

    def radio_mean_median_toggled(self):
        pass

    def btn_apply_segmentation_clicked(self):
        pass
    # endregion

    # region Option Menu
    def btn_equalize_clicked(self):
        self.edited_image = ih.equalize_image(self.edited_image)
        self.update_edited_figure()

    def radio_compare_clicked(self):
        self.update_edited_figure()

    def radio_hist_clicked(self):
        self.update_edited_figure()
    # endregion

    # region Actions Menu Bar
    def action_open_triggered(self):
        dlg = QFileDialog(self)
        dlg.setWindowTitle('Secione a imagem que deseja abrir.')
        dlg.setViewMode(QFileDialog.Detail)
        file_name = dlg.getOpenFileName(self, 'Open File')
        self.original_image = misc.imread(file_name, mode='L').astype(np.float64)
        print(self.original_image.dtype)
        self.edited_image = np.copy(self.original_image)
        self.setWindowTitle('Medical Images App' + file_name)
        self.update_original_figure()
        self.update_edited_figure()

    def action_reset_triggered(self):
        self.edited_image = np.copy(self.original_image)
        self.update_edited_figure()

    def action_undo_triggered(self):
        pass

    def action_see_history_triggered(self):
        pass

    def action_save_in_doc_triggered(self):
        pass

    def about(self):
        QMessageBox.about(
            self.centralwidget,
            "About",
            """     Medical Images App
    Italo Fernandes e Ronaldo Sena escreveram este código,
ele é livre para o uso, alterações e distribuição,
se de alguma maneira ele foi útil a você, agradeça com um café, ou uma cerveja.
    Mais informações: https://github.com/ronaldosena/imagens-medicas-2""")
    # endregion
    # endregion

    # region Update Figures
    def update_original_figure(self):
        if self.original_image.dtype == np.float64:
            min_value = min(self.original_image.ravel())
            max_value = max(self.original_image.ravel())
        else:
            min_value = np.iinfo(self.original_image.dtype).min
            max_value = np.iinfo(self.original_image.dtype).max
        self.original_image_fig.gca().imshow(
            self.original_image, cmap=plt.cm.gray, clim=(min_value, max_value))
        self.original_image_fig.gca().set_title('Original Image')
        self.original_image_canvas.draw()

    def update_edited_figure_image(self, min_value, max_value,
                                   title='Edited Image', img=None):
        if img is None:
            img = self.edited_image
        im = self.edited_image_fig.gca().imshow(
            img, cmap=plt.cm.gray, clim=(min_value, max_value))
        self.edited_image_fig.gca().set_title(title)
        return im

    def update_edited_figure_hist(self, im, min_value, max_value, img=None):
        if img is None:
            img = self.edited_image
        self.edited_image_fig.gca().hist(
            img.ravel(), bins=256, range=(min_value, max_value), normed=True)
        self.edited_image_fig.colorbar(im, orientation='horizontal')

    def update_edited_figure(self):
        self.edited_image_fig.clear()
        if self.radio_compare.isChecked():
            if self.original_image.dtype == np.float64:
                o_min_value = min(self.original_image.ravel())
                o_max_value = max(self.original_image.ravel())
            else:
                o_min_value = np.iinfo(self.original_image.dtype).min
                o_max_value = np.iinfo(self.original_image.dtype).max
            self.edited_image_fig.add_subplot(1+self.radio_hist.isChecked(),2, 1)
            im_original = self.update_edited_figure_image(o_min_value, o_max_value,
                                                          title='Original Image',
                                                          img=self.original_image)
            if self.radio_hist.isChecked():
                self.edited_image_fig.add_subplot(2, 2, 3)
                self.update_edited_figure_hist(im_original, o_min_value, o_max_value, img=self.original_image)

        if self.edited_image.dtype == np.float64:
            min_value = min(self.edited_image.ravel())
            max_value = max(self.edited_image.ravel())
        else:
            min_value = np.iinfo(self.edited_image.dtype).min
            max_value = np.iinfo(self.edited_image.dtype).max

        if self.radio_hist.isChecked() or self.radio_compare.isChecked():
            self.edited_image_fig.add_subplot(1+self.radio_hist.isChecked(),
                                              1+self.radio_compare.isChecked(),
                                              1+self.radio_compare.isChecked())

        im = self.update_edited_figure_image(min_value, max_value)

        if self.radio_hist.isChecked():
            self.edited_image_fig.add_subplot(2,
                                              1 +
                                              self.radio_compare.isChecked(),
                                              2 +
                                              2*self.radio_compare.isChecked())
            self.update_edited_figure_hist(im, min_value, max_value)

        self.edited_image_canvas.draw()
    # endregion

    def closeEvent(self, q_close_event):
        super(self.__class__, self).closeEvent(q_close_event)


def main():
    app = QApplication(sys.argv)
    form = IM2APP()
    form.show()
    app.exec_()

if __name__ == "__main__":
    main()
