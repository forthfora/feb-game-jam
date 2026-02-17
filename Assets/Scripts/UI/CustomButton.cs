using TMPro;
using UnityEngine;
using UnityEngine.EventSystems;

namespace GameJamProject
{
    public class ButtonTextColorChanger : MonoBehaviour, IPointerEnterHandler, IPointerExitHandler, IPointerDownHandler, IPointerUpHandler
    {
        public Color normalColor = Color.white;
        public Color hoverColor = Color.yellow;
        public Color clickColor = Color.red;
        
        private TMP_Text _buttonText;

        private void Start()
        {
            _buttonText = GetComponentInChildren<TMP_Text>();

            _buttonText.color = normalColor;
        }

        public void OnPointerEnter(PointerEventData eventData)
        {
            _buttonText.color = hoverColor;
        }

        public void OnPointerExit(PointerEventData eventData)
        {
            _buttonText.color = normalColor;
        }

        public void OnPointerDown(PointerEventData eventData)
        {
            _buttonText.color = clickColor;
        }

        public void OnPointerUp(PointerEventData eventData)
        {
            _buttonText.color = hoverColor;
        }
    }
}